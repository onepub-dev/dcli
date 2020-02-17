import 'dart:io';
import 'dart:developer';
import 'dart:isolate';

import 'package:dshell/dshell.dart';
import 'package:meta/meta.dart';

class Lock {
  String lockPath;
  String lockSuffix;
  String description;

  /// We use this to allow a projects lock to be-reentrant
  /// A non-zero value means we have the lock.
  /// We need to maintain a lock count per
  /// lock file//isolate to allow the lock file to be re-entrant.
  final Map<String, int> _lockCounts = {};

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

    Settings().setVerbose(true);
  }

  void withLock(
    void Function() fn, {
    String waiting,
  }) {
    /// Ensure that that the lockfile directory exists.
    if (!exists(lockPath)) {
      createDir(lockPath, recursive: true);
    }
    var lockCount = _lockCounts[_lockFilePath];
    try {
      lockCount ??= 0;

      Settings().verbose('_lockcount = $lockCount');

      if (lockCount > 0 || takeLock(waiting)) {
        lockCount++;

        fn();
      }
    } catch (e, st) {
      Settings()
          .verbose('Exception in withLoc ${e.toString()} ${st.toString()}');
    } finally {
      if (lockCount > 0) {
        lockCount--;
        if (lockCount == 0) {
          Settings().verbose('delete lock: $_lockFilePath');
          delete(_lockFilePath);
        }
      }
      _lockCounts[_lockFilePath] = lockCount;
    }
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

    // can't come and add a lock whilst we are looking for
    // a lock.
    touch(_lockFilePath, create: true);
    Settings().verbose('Created lockfile $_lockFilePath');

    // check for other lock files
    var locks = find('*.$lockSuffix', root: lockPath).toList();

    var lockFiles = locks.length;

    if (lockFiles == 1) {
      // no other lock exists so we have taken a lock.
      lockFiles = 0;
    } else {
      // we have found another lock file so check if it is held be a running process

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

        // wait for the lock to release or the timeout to expire
        var waitCount = 0;
        var infinite = false;
        if (timeout == null) {
          infinite = true;
        } else {
          waitCount = timeout.inSeconds;
        }

        if (waiting != null) print(waiting);
        var taken = false;
        while (infinite || waitCount > 0) {
          if (!ProcessHelper().isRunning(lpid)) {
            // If the foreign lock file was left orphaned
            // then we delete it.
            if (exists(lock)) {
              delete(lock);
            }
            taken = true;
            lockFiles--;
            break;
          }
          sleep(1);
          if (!infinite) {
            waitCount--;
          }
        }

        if (!taken) {
          throw LockException(
              'Unable to lock $description ${truepath(lockPath)} as it is currently held by ${ProcessHelper().getPIDName(lpid)} IsolateId: $isolateId');
        }
      }
    }

    return lockFiles == 0;
  }
}

class LockException extends DShellException {
  LockException(String message) : super(message);
}
