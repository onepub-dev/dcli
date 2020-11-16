import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'dart:isolate';

import 'package:meta/meta.dart';

import '../../dcli.dart';
import 'stack_trace_impl.dart';
import 'wait_for_ex.dart';

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
  /// The raw socket (udp) port we use to implement
  /// a hard lock. A port can only be opened once
  /// so its the perfect way to create a lock that works
  /// across processes and isolates.
  final int port = 63424;
  String _lockPath;

  /// The name of the lock.
  final String name;
  String _description;

  /// We use this to allow a lock to be-reentrant within an isolate.
  /// A non-zero value means we have the lock.
  /// We maintain a lock count per
  /// lock suffix to allow each suffix lock to be re-entrant.
  static final Map<String, int> _lockCounts = {};

  /// The duration to wait for a lock before timing out.
  final Duration _timeout;

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
    @required this.name,
    String lockPath,
    String description,
    Duration timeout,
  })  : _timeout = timeout ??= Duration(seconds: 30),
        _lockPath = lockPath,
        _description = description {
    assert(name != null);

    _lockPath ??= join(rootPath, Directory.systemTemp.path, 'dcli', 'locks');
    _description ??= '';
  }

  /// creates a lock file and then calls [fn]
  /// once [fn] returns the lock is released.
  /// If [waiting] is passed it will be used to write
  /// a log message to the console.
  void withLock(
    void Function() fn, {
    String waiting,
  }) {
    var lockHeld = false;
    runZoned(() {
      try {
        _log('lockcount = $_lockCountForName');

        if (_lockCountForName > 0 || _takeLock(waiting)) {
          lockHeld = true;
          incLockCount;

          fn();
        }
      } finally {
        if (lockHeld) _releaseLock();
        // just in case an async exception can be thrown
        // I'm uncertain if this is a reality.
        lockHeld = false;
      }
    },
        //ignore: avoid_types_on_closure_parameters
        onError: (Object e, StackTrace st) {
      if (lockHeld) _releaseLock();
      var stackTrace = StackTraceImpl.fromStackTrace(st);

      if (e is DCliException) {
        throw e.copyWith(stackTrace);
      } else {
        throw DCliException.from(e, stackTrace);
      }
    });
  }

  void _releaseLock() {
    if (_lockCountForName > 0) {
      decLockCount;

      if (_lockCountForName == 0) {
        Settings().verbose('Releasing lock: $_lockFilePath');

        _withHardLock(fn: () => delete(_lockFilePath));
      }
    }
  }

  int get _lockCountForName {
    var _lockCount = _lockCounts[name];
    _lockCount ??= 0;
    return _lockCount;
  }

  /// increments the lock count and returns
  /// the new lock count.
  int get incLockCount {
    var _lockCount = _lockCountForName;
    _lockCount++;
    _lockCounts[name] = _lockCount;
    _log('Incremented lock: $_lockCount');
    return _lockCount;
  }

  /// decrements the lock count and returns
  /// the new lock count.
  int get decLockCount {
    var _lockCount = _lockCountForName;
    _lockCount--;
    _lockCounts[name] = _lockCount;

    _log('Decremented lock: $_lockCountForName');
    return _lockCount;
  }

  String get _lockFilePath {
    // lock file is in the directory above the project
    // as during preparing we delete the project directory.

    var isolate = _isolateID;

    return join(_lockPath, '.$pid.${isolate}.$name');
  }

  _LockFileParts _lockFileParts(String lockfilePath) {
    var parts = basename(lockfilePath).split('.');
    // it can't actually be one of our lock files
    if (parts.length < 3) {
      return null;
    }

    var pid = int.tryParse(parts[1]);
    var isolateId = int.tryParse(parts[2]);

    return _LockFileParts(pid, isolateId);
  }

  int get _isolateID {
    var isolateString = Service.getIsolateID(Isolate.current);
    int isolateId;
    if (isolateString != null) {
      isolateString = isolateString.replaceAll(r'/', '_');
      isolateString = isolateString.replaceAll(r'\', '_');
      if (isolateString.contains('_')) {
        /// just the numeric value.
        isolateId = int.tryParse(isolateString.split('_')[1]);
      }
    }
    isolateId ??= Isolate.current.hashCode;
    return isolateId;
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
  bool _takeLock(String waiting) {
    var taken = false;

    // wait for the lock to release or the timeout to expire
    var waitCount = 1;
    if (_timeout != null) {
      // we will be retrying every 100 ms.
      waitCount = _timeout.inMilliseconds ~/ 100;
      // ensure at least one retry
      if (waitCount == 0) {
        waitCount = 1;
      }
    }

    while (!taken && waitCount > 0) {
      _withHardLock(fn: () {
        /// Ensure that that the lockfile directory exists.
        if (!exists(_lockPath)) {
          createDir(_lockPath, recursive: true);
        }
        // check for other lock files
        var locks =
            find('*.$name', root: _lockPath, includeHidden: true, recursive: false).toList();
        _log(red('found $locks lock files'));

        var lockFiles = locks.length;

        if (lockFiles == 0) {
          // no other lock exists so we have taken a lock.
          taken = true;
        } else {
          // we have found another lock file so check if it is held be a running process
          lockFiles = _clearStaleLocks(locks, lockFiles);
          if (lockFiles == 0) {
            taken = true;
          }
        }

        if (taken) {
          var isolateID = Service.getIsolateID(Isolate.current);
          Settings()
              .verbose('Taking lock ${basename(_lockFilePath)} for $isolateID');

          Settings().verbose(
              'Lock Source: ${StackTraceImpl(skipFrames: 9).formatStackTrace(methodCount: 1)}');
          touch(_lockFilePath, create: true);
          //  log(StackTraceImpl().formatStackTrace(methodCount: 100));
        }
      });

      /// sleep for 100ms and then we will try again.
      waitForEx<void>(Future.delayed(Duration(milliseconds: 100)));
      if (waiting != null) {
        print(waiting);
        // only print waiting message once.
        waiting = null;
      }

      if (waitCount > 0) {
        waitCount--;
      }
    }

    if (!taken) {
      if (waitCount == 0) {
        throw LockException(
            'NamedLock timedout on $_description ${truepath(_lockPath)} as it is currently held');
      } else {
        throw LockException(
            'Unable to lock $_description ${truepath(_lockPath)} as it is currently held');
      }
    }

    return taken;
  }

  int _clearStaleLocks(List<String> locks, int lockFiles) {
    for (var lock in locks) {
      var lockFileParts = _lockFileParts(lock);
      if (lockFileParts == null) {
        /// isn't a valid lock file so ignore.
        continue;
      }
      var currentIsolateId = _isolateID;
      if (lockFileParts.pid == pid &&
          lockFileParts.isolateId == currentIsolateId) {
        // ignore our own lock.
        lockFiles--;
        continue;
      }

      if (!ProcessHelper().isRunning(lockFileParts.pid)) {
        // If the foreign lock file was left orphaned
        // then we delete it.
        if (exists(lock)) {
          _log(red('Clearing old lock file: $lock'));
          delete(lock);
        }
        lockFiles--;
      }
    }
    return lockFiles;
  }

  void _withHardLock({
    Duration timeout,
    void Function() fn,
  }) {
    RawServerSocket socket;

    var waitCount = -1;

    if (timeout != null) {
      waitCount = timeout.inMilliseconds ~/ 100;
      // ensure at least one retry.
      if (waitCount == 0) waitCount = 1;
    }

    try {
      while (socket == null) {
        socket = waitForEx<RawServerSocket>(_bindSocket());
        if (waitCount > 0) {
          waitCount--;
        }

        if (waitCount == 0) {
          // we have timed out
          break;
        }
        if (socket == null) {
          waitForEx<void>(Future.delayed(Duration(milliseconds: 100)));
        }
      }

      if (socket != null) {
        _log(blue('Hardlock taken'));
        fn();
      }
    } finally {
      if (socket != null) {
        socket.close();
        _log(blue('Hardlock released'));
      }
    }
  }

  Future<RawServerSocket> _bindSocket() async {
    RawServerSocket socket;
    try {
      socket = await RawServerSocket.bind(
        '127.0.0.1',
        port,
      );
    } on SocketException catch (_) {
      /// no op. We expect this if the hardlock is already held.
    }
    return socket;
  }
}

void _log(String message) {
  Settings().verbose(message);
}

class _LockFileParts {
  int pid;
  int isolateId;

  _LockFileParts(this.pid, this.isolateId);
}

///
class LockException extends DCliException {
  ///
  LockException(String message) : super(message);
}
