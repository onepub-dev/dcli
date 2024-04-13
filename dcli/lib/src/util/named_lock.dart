/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../dcli.dart';

/// A [NamedLock] can be used to control access to a resource
/// across processes and isolates.
///
/// A [NamedLock] uses a combination of a UDP socket and a files
/// to provide a locking mechanism that is guarenteed to work across
/// isolates in the same process as well as between processes.
///
/// If you only need locking 'within' an isolate that you should
/// avoid using [NamedLock] as it is a realitively slow locking
/// mechanism as it creates a file to represent a lock.
///
/// To ensure that [NamedLock]s hold across processes and isolates
/// we use a two part locking mechanism.
/// The first part is a TCP socket (on port 9003) that we
/// refer to as a hard lock.  The same hard lock is used for all
/// [NamedLock]s and as such is a potential bottle neck. To limit
/// this bottle neck we hold the hard lock for as short a period as possible.
/// The hard lock is only used to create and delete the file based lock.
/// As soon as a file based lock transition completes,
///  the hard lock is released.
///
/// On linux a traditional file lock will not block isolates
/// in the same process from locking the same file hence we need to use
/// a NamedLock between isolates as well as processes.
class NamedLock {
  /// [lockPath] is the path of the directory used
  /// to store the lock file.
  /// If no lockPath is given then [Directory.systemTemp]/dcli/locks is used
  /// to store locks.
  /// All code that shares the lock MUST use the
  /// same [lockPath]. It is recommended that you
  /// pass an absolute path to ensure that the
  /// same path is used.
  /// The [suffix] is used as the suffix of the lockfile name.
  /// The suffix allows multiple locks to share a single
  /// lockPath.
  /// The [description], if passed, is used in error messages
  /// to describe the lock.
  /// The [timeout] defines how long we will wait for
  /// a lock to become available. The default [timeout] is
  /// infinite (null).
  ///
  /// ```dart
  /// NamedLock(name: 'update-catalog').withLock(() {
  ///   if (!exists('catalog'))
  ///     createDir('catalog');
  ///   updateCatalog();
  /// });
  /// ```
  ///
  NamedLock({
    required this.suffix,
    String? lockPath,
    String description = '',
    Duration timeout = const Duration(seconds: 30),
  })  : _timeout = timeout,
        _description = description {
    _lockPath =
        lockPath ?? join(rootPath, Directory.systemTemp.path, 'dcli', 'locks');
  }

  /// The tcp socket  port we use to implement
  /// a hard lock. A port can only be opened once
  /// so its the perfect way to create a lock that works
  /// across processes and isolates.
  final int port = 9003;

  /// Path to the directory where the lock files are stored.
  late String _lockPath;

  /// The name of the lock.
  final String suffix;
  final String _description;

  /// We maintain a lock count per
  /// lock suffix to allow each suffix lock to be re-entrant
  /// within a single isolate.
  static final Map<String, int> _lockCounts = {};

  /// The duration to wait for a lock before timing out.
  final Duration _timeout;

  /// creates a lock file and then calls [action]
  /// once [action] returns the lock is released.
  /// If [waiting] is passed it will be used to write
  /// a log message to the console.
  ///
  /// Throws a [DCliException] if the NamedLock times out.
  Future<void> withLock(
    Future<void> Function() action, {
    String? waiting,
  }) async {
    final callingStackTrace = Trace.current();
    var lockHeld = false;
    return runZonedGuarded(() async {
      try {
        verbose(() => 'withLock called for $_lockFilePath');

        _createLockPath();

        if (_lockCountForName > 0 || await _takeLock(waiting)) {
          lockHeld = true;
          incLockCount;

          await action();
        }
      } finally {
        if (lockHeld) {
          await _releaseLock();
        }
        // just in case an async exception can be thrown
        // I'm uncertain if this is a reality.
        lockHeld = false;
        verbose(() => 'withLock completed for $_lockFilePath');
      }
    }, (e, st) async {
      if (lockHeld) {
        await _releaseLock();
      }
      verbose(() => 'Exception throw $e : $e');
      if (e is DCliException) {
        throw e..stackTrace = callingStackTrace;
      } else {
        throw DCliException.from(e, callingStackTrace);
      }
    });
  }

  void _createLockPath() {
    if (!exists(_lockPath)) {
      try {
        createDir(_lockPath, recursive: true);
      } on CreateDirException catch (_) {
        /// we can get a race condition on the
        /// create so just ignore it.
      }
    }
  }

  Future<void> _releaseLock() async {
    if (_lockCountForName > 0) {
      decLockCount;

      /// decLockCount changes the value of _locakCountForName
      /// but the static analyser can't see this.
      // ignore: invariant_booleans
      if (_lockCountForName == 0) {
        verbose(() => 'Releasing lock: $_lockFilePath');

        await _withHardLock(fn: () async => delete(_lockFilePath));

        verbose(() => 'Released lock: $_lockFilePath');
      }
    }
  }

  int get _lockCountForName {
    var lockCount = _lockCounts[suffix];
    return lockCount ??= 0;
  }

  /// increments the lock count and returns
  /// the new lock count.
  int get incLockCount {
    var lockCount = _lockCountForName;
    lockCount++;
    _lockCounts[suffix] = lockCount;
    verbose(() => 'Incremented lock: $lockCount');
    return lockCount;
  }

  /// decrements the lock count and returns
  /// the new lock count.
  int get decLockCount {
    var lockCount = _lockCountForName;
    lockCount--;
    _lockCounts[suffix] = lockCount;

    verbose(() => 'Decremented lock: $_lockCountForName');
    return lockCount;
  }

  String get _lockFilePath {
    // lock file is in the directory above the project
    // as during preparing we delete the project directory.

    final isolate = _isolateID;

    return join(_lockPath, '.$pid.$isolate.$suffix');
  }

  _LockFileParts? _lockFileParts(String lockfilePath) {
    final parts = basename(lockfilePath).split('.');
    // it can't actually be one of our lock files
    if (parts.length < 3) {
      return null;
    }

    final pid = int.tryParse(parts[1]) ?? 0;
    final isolateId = int.tryParse(parts[2]) ?? 0;

    return _LockFileParts(pid, isolateId);
  }

  int get _isolateID {
    String? isolateString;

    try {
      isolateString = Service.getIsolateId(Isolate.current);
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      /// hack until google fixes nndb problem with getIsolateID
      /// https://github.com/dart-lang/sdk/issues/45347
    }
    int? isolateId;
    if (isolateString != null) {
      isolateString = isolateString.replaceAll('/', '_');
      isolateString = isolateString.replaceAll(r'\', '_');
      if (isolateString.contains('_')) {
        /// just the numeric value.
        isolateId = int.tryParse(isolateString.split('_')[1]);
      }
    }
    return isolateId ??= Isolate.current.hashCode;
  }

  /// Attempts to take a project lock.
  /// We wait for upto 30 seconds for an existing lock to
  /// be released and then give up.
  ///
  /// We create the lock file in the virtual project directory
  /// in the form:
  /// <pid>.warmup.lock
  ///
  /// If we find an existing lock file we check if the process
  /// that owns it is still running. If it isn't we
  /// take a lock and delete the orphaned lock.
  Future<bool> _takeLock(String? waiting) async {
    var taken = false;
    verbose(() => '_takeLock called for: $_lockFilePath');

    var finalwaiting = waiting;

    // wait for the lock to release or the timeout to expire
    var waitCount = 1;

    // we will be retrying every 100 ms.
    waitCount = _timeout.inMilliseconds ~/ 100;
    // ensure at least one retry
    if (waitCount == 0) {
      waitCount = 1;
    }

    /// If a valid lock file exists we don't even try to take
    /// a hard lock.
    /// This is to avoid a pseudo race condition under heavy load
    /// where the lock owner can't get the hardlock as
    /// all of the contenders constantly have it locked.
    while (!taken && waitCount > 0) {
      verbose(() => 'entering withHardLock $waitCount for $_lockFilePath');

      if (!_validLockFileExists) {
        await _withHardLock(
          fn: () async {
            // check for other lock files
            final locks = find(
              '*.$suffix',
              workingDirectory: _lockPath,
              includeHidden: true,
              recursive: false,
            ).toList();
            verbose(() => red('found lock files $locks'));

            var lockFiles = locks.length;

            if (lockFiles == 0) {
              // no other lock exists so we have taken a lock.
              taken = true;
            } else {
              // we have found another lock file so check if it is held
              // be a running process
              lockFiles = _clearStaleLocks(locks, lockFiles);
              if (lockFiles == 0) {
                taken = true;
              }
            }

            if (taken) {
              final isolateID = _isolateID;
              Settings().verbose(
                'Taking lock ${basename(_lockFilePath)} for $isolateID',
              );

              verbose(
                () => 'Lock Source: '
                    // ignore: lines_longer_than_80_chars
                    '${Trace.current(9).frames[0]}',
              );
              touch(_lockFilePath, create: true);
            }
          },
        );
      }

      /// sleep for 100ms and then we will try again.
      sleep(100, interval: Interval.milliseconds);
      if (finalwaiting != null) {
        // only print waiting message once.
        finalwaiting = null;
      }

      waitCount--;
    }

    if (!taken) {
      if (waitCount == 0) {
        throw LockException(
          'NamedLock timed out on $_description '
          '${truepath(_lockPath)} as it is currently held',
        );
      } else {
        throw LockException(
          'Unable to lock $_description '
          '${truepath(_lockPath)} as it is currently held',
        );
      }
    }

    verbose(() => 'lock Taken for: $_lockFilePath');

    return taken;
  }

  /// Check if there is a valid lock file and if so
  /// if it has a live owner.
  bool get _validLockFileExists {
    // check for other lock files
    final locks = find(
      '*.$suffix',
      workingDirectory: _lockPath,
      includeHidden: true,
      recursive: false,
    ).toList();

    for (final lock in locks) {
      final lockFileParts = _lockFileParts(lock);
      if (lockFileParts == null) {
        /// isn't a valid lock file so ignore.
        continue;
      }
      if (_isSelf(lockFileParts.pid, lockFileParts.isolateId)) {
        continue;
      }

      if (_isOwnerLive(lockFileParts.pid)) {
        return true;
      }
    }
    return false;
  }

  bool _isSelf(int lockPid, int lockIsolateId) =>
      lockIsolateId == _isolateID && lockPid == pid;

  int _clearStaleLocks(List<String> locks, int lockFiles) {
    var lockFiles0 = lockFiles;
    for (final lock in locks) {
      final lockFileParts = _lockFileParts(lock);
      if (lockFileParts == null) {
        /// isn't a valid lock file so ignore.
        continue;
      }
      if (_isSelf(lockFileParts.pid, lockFileParts.isolateId)) {
        // ignore our own lock.
        lockFiles0--;
        continue;
      }

      if (!_isOwnerLive(lockFileParts.pid)) {
        // If the foreign lock file was left orphaned
        // then we delete it.
        if (exists(lock)) {
          verbose(() => red('Clearing old lock file: $lock'));
          delete(lock);
        }
        lockFiles0--;
      }
    }
    return lockFiles0;
  }

  bool _isOwnerLive(int lockOwnerPid) =>
      ProcessHelper().isRunning(lockOwnerPid);

  Future<void> _withHardLock({
    required Future<void> Function() fn,
  }) async {
    ServerSocket? socket;

    try {
      verbose(() => 'attempt bindSocket');
      // ignore: discarded_futures
      socket = await _bindSocket();

      verbose(() => blue('Hardlock taken'));
      await fn();
    } finally {
      if (socket != null) {
        await socket.close();
        verbose(() => blue('Hardlock released'));
      }
    }
  }

  Future<ServerSocket?> _bindSocket() async {
    ServerSocket? socket;
    try {
      socket = await ServerSocket.bind(
        '127.0.0.1',
        port,
      );
    } on SocketException catch (e) {
      /// no op. We expect this if the hardlock is already held.
      verbose(e.toString);
    }
    return socket;
  }
}

class _LockFileParts {
  _LockFileParts(this.pid, this.isolateId);

  int pid;
  int isolateId;
}

///
class LockException extends DCliException {
  ///
  LockException(super.message);
}
