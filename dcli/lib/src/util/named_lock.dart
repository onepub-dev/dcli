/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:path/path.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../dcli.dart';
import 'isolate_id.dart';

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
/// The first part is a UDP socket (on port 63424) that we
/// refere to a hard lock.  The same hard lock is used for all
/// [NamedLock]s and as such is a potential bottle neck. To limit
/// this bottle neck we hold the hard lock for as short a period as possible.
/// The hard lock is only used to create and delete the file based lock.
/// As soon as a file based lock transition completes the hard lock is released.
///
/// On linux a traditional file lock will not block isolates
/// in the same process from locking the same file hence we need
class NamedLock {
  /// [lockPath] is the path of the directory used
  /// to store the lock file.
  /// If no lockPath is given then [Directory.systemTemp]/dcli/locks is used
  /// to store locks.
  /// All code that shares the lock MUST use the
  /// same [lockPath]. It is recommended that you
  /// pass an absolute path to ensure that the
  /// same path is used.
  /// The [name] is used as the suffix of the lockfile.
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
    required this.name,
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
  late String _lockPath;

  /// The name of the lock.
  final String name;
  final String _description;

  /// We use this to allow a lock to be-reentrant within an isolate.
  /// A non-zero value means we have the lock.
  /// We maintain a lock count per
  /// lock suffix to allow each suffix lock to be re-entrant.
  static final Map<String, int> _lockCounts = {};

  /// The duration to wait for a lock before timing out.
  final Duration _timeout;

  @Deprecated('Used withLockAsync')
  Future<void> withLock(
    void Function() fn, {
    String? waiting,
  }) =>
      throw UnsupportedError('Use withLockAsync');

  /// creates a lock file and then calls [fn]
  /// once [fn] returns the lock is released.
  /// If [waiting] is passed it will be used to write
  /// a log message to the console.
  ///
  /// Throws a [DCliException] if the NamedLock times out.
  Future<void> withLockAsync(
    Future<void> Function() fn, {
    String? waiting,
  }) async {
    var lockHeld = false;
    try {
      verbose(() => 'lockcount = $_lockCountForName');

      _createLockPath();

      if (_lockCountForName > 0 || (await _takeLock(waiting))) {
        lockHeld = true;
        incLockCount;

        await fn();
      }
    } finally {
      if (lockHeld) {
        await _releaseLock();
      }
      // just in case an async exception can be thrown
      // I'm uncertain if this is a reality.
      lockHeld = false;
    }
  }

  void _createLockPath() {
    if (!exists(_lockPath)) {
      try {
        createDir(_lockPath, recursive: true);
      } on CreateDirException catch (_) {
        /// we can get a race condition on the
        /// create so just ignore it because
        /// if the path already exists our job
        /// is down.
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

        verbose(() => 'Releasing lock: $_lockFilePath');
      }
    }
  }

  int get _lockCountForName {
    var lockCount = _lockCounts[name];
    return lockCount ??= 0;
  }

  /// increments the lock count and returns
  /// the new lock count.
  int get incLockCount {
    var lockCount = _lockCountForName;
    lockCount++;
    _lockCounts[name] = lockCount;
    verbose(() => 'Incremented lock: $lockCount');
    return lockCount;
  }

  /// decrements the lock count and returns
  /// the new lock count.
  int get decLockCount {
    var lockCount = _lockCountForName;
    lockCount--;
    _lockCounts[name] = lockCount;

    verbose(() => 'Decremented lock: $_lockCountForName');
    return lockCount;
  }

  String get _lockFilePath {
    // lock file is in the directory above the project
    // as during preparing we delete the project directory.

    final isolate = isolateID;

    return join(_lockPath, '.$pid.$isolate.$name');
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
    verbose(() => '_takeLock called');

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
    /// This is to avoid a pseudp race condition under heavy load
    /// where the lock owner can't get the hardlock as
    /// all of the contenders constantly have it locked.
    while (!taken && waitCount > 0) {
      if (!_validLockFileExists) {
        verbose(() => 'entering withHardLock waitCount: $waitCount');

        /// Take a hard lock and attempt to create a lock file.
        await _withHardLock(
          fn: () async {
            // check for a lock files again as one may have
            // been created between checking for their existance
            // and the hard lock been taken.
            final locks = find(
              '*.$name',
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
              Settings().verbose(
                'Taking lock ${basename(_lockFilePath)} for $isolateID',
              );

              verbose(
                () => 'Lock Source: '
                    // ignore: lines_longer_than_80_chars
                    '${Trace.current().frames.length > 1 ? Trace.current().frames[min(Trace.current().frames.length - 1, 8)] : 'Unknown'}',
              );
              touch(_lockFilePath, create: true);
            }
          },
        );
      } else {
        verbose(() => 'existing lock file exist so waiting');
      }

      /// sleep for 100ms and then we will try again.
      await Future.delayed(const Duration(milliseconds: 100), () {});
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

    return taken;
  }

  /// Check if there is a valid lock file and if so
  /// if it has a live owner.
  bool get _validLockFileExists {
    // check for other lock files
    final locks = find(
      '*.$name',
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
      lockIsolateId == isolateID && lockPid == pid;

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

  /// Call [fn] with a hard lock held.
  Future<void> _withHardLock({
    required Future<void> Function() fn,
  }) async {
    ServerSocket? socket;

    try {
      verbose(() => 'attempt bindSocket');
      // ignore: discarded_futures
      socket = await _bindSocket();
      if (socket != null) {
        verbose(() => blue('''
Hardlock taken for $name in ${Service.getIsolateId(Isolate.current)}'''));
        await fn();
      }
    } finally {
      if (socket != null) {
        await socket.close();
        verbose(() => blue('''
Hardlock released  for $name in ${Service.getIsolateId(Isolate.current)}'''));
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
