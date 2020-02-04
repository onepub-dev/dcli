import 'dart:io';

import 'package:dshell/src/script/virtual_project.dart';
import 'package:path/path.dart';

import '../../../dshell.dart';

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
bool takeLock(VirtualProject project) {
  var taken = false;

  const lockSuffix = 'clean.lock';

  var lockFile = join(project.path, '$pid.${lockSuffix}');

  assert(!exists(lockFile));

  try {
    // we take a lock up front so someone else
    // can't come and add a lock whilst we are looking for
    // a lock.
    touch(lockFile, create: true);

    // check for other lock files
    var locks = find('*.clean.lock', root: project.path).toList();

    if (locks.length == 1) {
      // no other lock exists so we have taken a lock.
      taken = true;
    } else {
      // we have found another lock file so check if it is held be an running process
      for (var lock in locks) {
        var parts = lock.split('.');
        if (parts.length != 3) {
          // it can't actually be one of our lock files so ignore it
          continue;
        }
        var lpid = int.tryParse(parts[0]);

        if (lpid == pid) {
          // ignore our own lock.
          continue;
        }

        // wait for the lock to release
        var released = false;
        var waitCount = 30;
        while (waitCount > 0) {
          sleep(1);
          if (!ProcessHelper().isRunning(lpid)) {
            // If the forign lock file was left orphaned
            // then we delete it.
            if (exists(lock)) {
              delete(lock);
            }
            released = true;
            break;
          }
          waitCount--;
        }

        if (!released) {
          taken = true;
        }
      }
    }
  } finally {
    if (taken == false) {
      // if we couldn't take a lock then we should release ours.
      delete(lockFile);
    }
  }
  return taken;
}
