import 'dart:io';
import 'dart:developer';
import 'dart:isolate';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/waitForEx.dart';
import 'package:meta/meta.dart';

import 'stack_trace_impl.dart';

class Lock {
  int port = 63424;
  String lockPath;
  String lockSuffix;
  String description;

  /// We use this to allow a projects lock to be-reentrant
  /// A non-zero value means we have the lock.
  /// We need to maintain a lock count per
  /// lock suffix to allow each suffix lock to be re-entrant.
  static final Map<String, int> _lockCounts = {};

  Duration timeout;

  /// [lockPath] is the path of the directory used
  /// to store the lock file.
  /// If no lockPath is given then [Directory.systemTemp]/dshell/locks is used
  /// to store locks.
  /// All code that shares the lock MUST use the
  /// same [lockPath]. It is recommended that you
  /// pass an absolute path to ensure that the
  /// same path is used.
  /// The [lockSuffix] is used as the suffix of the lockfile.
  /// The suffix allows multiple locks to share a single
  /// lockPath.
  /// The [description], if passed, is used in error messages
  /// to describe the lock.
  /// The [timeout] field defines how long we will wait for
  /// a lock to become available. The default [timeout] is
  /// infinite (null).
  ///
  Lock({
    @required this.lockSuffix,
    this.lockPath,
    this.description,
    this.timeout,
  }) {
    assert(lockSuffix != null);
    lockPath ??= join('/', Directory.systemTemp.path, 'dshell', 'locks');
    description ??= '';

    //Settings().setVerbose(true);
  }

  void withLock(
    void Function() fn, {
    String waiting,
  }) {
    /// Ensure that that the lockfile directory exists.
    withHardLock(fn: () {
      if (!exists(lockPath)) {
        createDir(lockPath, recursive: true);
      }
    });

    try {
      log('lockcount = ${lockCount}');

      if (lockCount > 0 || takeLock(waiting)) {
        incLockCount;

        fn();
      }
    } catch (e, st) {
      log('Exception in withLock ${e.toString()} ${st.toString()}');
    } finally {
      if (lockCount > 0) {
        decLockCount;

        if (lockCount == 0) {
          log(red('delete lock: $_lockFilePath'));

          withHardLock(fn: () => delete(_lockFilePath));
        }
      }
    }
  }

  int get lockCount {
    var _lockCount = _lockCounts[lockSuffix];
    _lockCount ??= 0;
    return _lockCount;
  }

  /// increments the lock count and returns
  /// the new lock count.
  int get incLockCount {
    var _lockCount = lockCount;
    _lockCount++;
    _lockCounts[lockSuffix] = _lockCount;
    log(orange('Incremented lock: $_lockCount'));
    return _lockCount;
  }

  /// decrements the lock count and returns
  /// the new lock count.
  int get decLockCount {
    var _lockCount = lockCount;
    _lockCount--;
    _lockCounts[lockSuffix] = _lockCount;

    log(orange('Decremented lock: $lockCount'));
    return _lockCount;
  }

  String get _lockFilePath {
    // lock file is in the directory above the project
    // as during cleaning we delete the project directory.

    var isolate = Service.getIsolateID(Isolate.current);
    isolate = isolate.replaceAll('/', '_');
    return join(lockPath, '$pid.$isolate.${lockSuffix}');
  }

  /// Attempts to take a project lock.
  /// We wait for upto 30 seconds for an existing lock to
  /// be released and then give up.
  ///
  /// We create the lock file in the virtual project directory
  /// in the form:
  /// <pid>.clean.lock
  ///
  /// If we find an existing lock file we check if the process
  /// that owns it is still running. If it isn't we
  /// take a lock and delete the orphaned lock.
  bool takeLock(String waiting) {
    assert(exists(lockPath));

    var taken = false;

    // wait for the lock to release or the timeout to expire
    var waitCount = -1;
    if (timeout != null) {
      waitCount = timeout.inSeconds;
    }

    while (!taken && waitCount != 0) {
      withHardLock(fn: () {
        // check for other lock files
        var locks = find('*.$lockSuffix', root: lockPath).toList();

        var lockFiles = locks.length;

        if (lockFiles == 0) {
          // no other lock exists so we have taken a lock.
          taken = true;
        } else {
          // we have found another lock file so check if it is held be a running process
          lockFiles = clearOldLocks(locks, lockFiles);
          if (lockFiles == 0) {
            taken = true;
          }
        }

        if (taken) {
          log(green('Taking lock $_lockFilePath'));
          touch(_lockFilePath, create: true);
          //  log(StackTraceImpl().formatStackTrace(methodCount: 100));
        }
      });
      sleep(1);
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
      throw LockException(
          'Unable to lock $description ${truepath(lockPath)} as it is currently held'); //  by ${ProcessHelper().getPIDName(lpid)} IsolateId: $isolateId');
    }

    return taken;
  }

  int clearOldLocks(List<String> locks, int lockFiles) {
    for (var lock in locks) {
      var parts = basename(lock).split('.');
      if (parts.length < 3) {
        // it can't actually be one of our lock files so ignore it
        continue;
      }
      var lpid = int.tryParse(parts[0]);
      var isolateId = parts[1];
      var currentIsolateId = Service.getIsolateID(Isolate.current);
      currentIsolateId = currentIsolateId.replaceAll('/', '_');

      if (lpid == pid && isolateId == currentIsolateId) {
        // ignore our own lock.
        lockFiles--;
        continue;
      }

      if (!ProcessHelper().isRunning(lpid)) {
        // If the foreign lock file was left orphaned
        // then we delete it.
        if (exists(lock)) {
          log(red('Clearing old lock file: $lock'));
          delete(lock);
        }
        lockFiles--;
      }
    }
    return lockFiles;
  }

  void withHardLock({
    Duration timeout,
    void Function() fn,
  }) {
    RawDatagramSocket socket;

    var waitCount = -1;

    if (timeout != null) waitCount = timeout.inSeconds;

    try {
      while (socket == null) {
        socket = waitForEx<RawDatagramSocket>(RawDatagramSocket.bind(
          '127.0.0.172',
          port,
          reuseAddress: true,
          reusePort: true,
        ));

        if (waitCount > 0) {
          waitCount--;
        }

        if (waitCount == 0) {
          // we have timedout
          break;
        }
        if (socket == null) {
          sleep(1);
        }
      }

      if (socket != null) {
        log(blue('Hardlock taken'));
        fn();
      }
    } finally {
      if (socket != null) {
        socket.close();
        log(blue('Hardlock relased'));
      }
    }
  }
}

void log(String message) {
  var id = Service.getIsolateID(Isolate.current);
  //print('$id: $message');
}

class LockException extends DShellException {
  LockException(String message) : super(message);
}
