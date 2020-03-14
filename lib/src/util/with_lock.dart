import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'dart:isolate';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/stack_trace_impl.dart';
import 'package:dshell/src/util/wait_for_ex.dart';
import 'package:meta/meta.dart';

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
  int port = 63424;
  String lockPath;
  String name;
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
  /// The [name] is used as the suffix of the lockfile.
  /// The suffix allows multiple locks to share a single
  /// lockPath.
  /// The [description], if passed, is used in error messages
  /// to describe the lock.
  /// The [timeout] field defines how long we will wait for
  /// a lock to become available. The default [timeout] is
  /// infinite (null).
  ///
  NamedLock({
    @required this.name,
    this.lockPath,
    this.description,
    this.timeout,
  }) {
    assert(name != null);
    lockPath ??= join(rootPath, Directory.systemTemp.path, 'dshell', 'locks');
    description ??= '';

    //Settings().setVerbose(true);
  }

  void withLock(
    void Function() fn, {
    String waiting,
  }) {
    var lockHeld = false;
    runZoned(() {
      /// Ensure that that the lockfile directory exists.
      withHardLock(fn: () {
        if (!exists(lockPath)) {
          createDir(lockPath, recursive: true);
        }
      });

      try {
        log('lockcount = ${lockCount}');

        if (lockCount > 0 || takeLock(waiting)) {
          lockHeld = true;
          incLockCount;

          fn();
        }
      } finally {
        releaseLock();
        // just in case an async exception can be thrown
        // I'm uncertain if this is a reality.
        lockHeld = false;
      }
    }, onError: (Object e, StackTrace st) {
      if (lockHeld) releaseLock();
      //var stackTrace = StackTraceImpl.fromStackTrace(st, skipFrames: 10);
      var stackTrace = StackTraceImpl.fromStackTrace(st);
      Settings().verbose(stackTrace.formatStackTrace());

      if (e is DShellException) {
        throw e.copyWith(stackTrace);
      } else {
        throw DShellException.from(e, stackTrace);
      }
    });
  }

  void releaseLock() {
    if (lockCount > 0) {
      decLockCount;

      if (lockCount == 0) {
        Settings().verbose(red('Releasing lock: $_lockFilePath'));

        withHardLock(fn: () => delete(_lockFilePath));
      }
    }
  }

  int get lockCount {
    var _lockCount = _lockCounts[name];
    _lockCount ??= 0;
    return _lockCount;
  }

  /// increments the lock count and returns
  /// the new lock count.
  int get incLockCount {
    var _lockCount = lockCount;
    _lockCount++;
    _lockCounts[name] = _lockCount;
    log(orange('Incremented lock: $_lockCount'));
    return _lockCount;
  }

  /// decrements the lock count and returns
  /// the new lock count.
  int get decLockCount {
    var _lockCount = lockCount;
    _lockCount--;
    _lockCounts[name] = _lockCount;

    log(orange('Decremented lock: $lockCount'));
    return _lockCount;
  }

  String get _lockFilePath {
    // lock file is in the directory above the project
    // as during cleaning we delete the project directory.

    var isolate = Service.getIsolateID(Isolate.current);
    isolate = isolate.replaceAll(r'/', '_');
    isolate = isolate.replaceAll(r'\', '_');
    return join(lockPath, '$pid.$isolate.${name}');
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
        var locks = find('*.$name', root: lockPath).toList();

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
          var isolateID = Service.getIsolateID(Isolate.current);
          Settings().verbose(
              orange('Taking lock ${basename(_lockFilePath)} for $isolateID'));

          Settings().verbose(
              'Lock Source: ${StackTraceImpl(skipFrames: 9).formatStackTrace(methodCount: 1)}');
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
      currentIsolateId = currentIsolateId.replaceAll(r'\', '_');
      currentIsolateId = currentIsolateId.replaceAll(r'/', '_');

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
      var reusePort = Settings().isWindows ? false : true;
      while (socket == null) {
        socket = waitForEx<RawDatagramSocket>(RawDatagramSocket.bind(
          '127.0.0.172',
          port,
          reuseAddress: true,
          reusePort: reusePort,
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
  // var id = Service.getIsolateID(Isolate.current);
  //print('$id: $message');
}

class LockException extends DShellException {
  LockException(String message) : super(message);
}
