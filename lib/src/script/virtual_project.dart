import 'dart:io';
import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/functions/read.dart';
import 'package:dshell/src/util/ansi_color.dart';
import 'package:dshell/src/util/process_helper.dart';
import 'package:dshell/src/util/truepath.dart';
import 'package:path/path.dart';

import '../../dshell.dart';
import '../functions/is.dart';
import '../pubspec/pubspec.dart';
import '../pubspec/pubspec_file.dart';
import '../pubspec/pubspec_manager.dart';
import 'pub_get.dart';

import '../settings.dart';
import 'dart_sdk.dart';
import 'script.dart';

/// Creates project directory structure
/// All projects live under the dshell cache
/// directory are form a virtual copy of the
/// user's Script with the additional files
/// required by dart.
class VirtualProject {
  static const String PROJECT_DIR = '.project';
  final Script script;

  String _virtualProjectPath;

  // The absolute path to the scripts lib directory.
  // The script may not have a lib in which
  // case this directory wont' exist.
  String _scriptLibPath;

  // The absolute path to the projects lib directory.
  // If the script lib exists then this will
  // be a link to that directory.
  // If the script lib doesn't exist then
  // on will be created under the virtual project directory.
  String _projectLibPath;

  // A path to the 'Link' file in the project directory
  // that links to the actual script file.
  String _projectScriptLinkPath;

  // String _projectPubSpecPath;

  /// Returns a [project] instance for the given
  /// script.
  VirtualProject(String cacheRootPath, this.script) {
    // /home/bsutton/.dshell/cache/home/bsutton/git/dshell/test/test_scripts/hello_world.project
    _virtualProjectPath = join(cacheRootPath,
        script.scriptDirectory.substring(1), script.basename + PROJECT_DIR);

    _projectLibPath = join(_virtualProjectPath, 'lib');
    _projectScriptLinkPath = join(_virtualProjectPath, script.scriptname);
    _scriptLibPath = join(script.scriptDirectory, 'lib');
  }

  String get scriptLib => _scriptLibPath;
  String get projectCacheLib => _projectLibPath;

  /// The  absolute path to the
  /// virtual project's project directory.
  /// This is this is essentially:
  /// join(Settings().dshellCache, dirname(script), PROJECT_DIR)
  ///
  String get path => _virtualProjectPath;

  String get pubSpecPath => join(_virtualProjectPath, 'pubspec.yaml');

  /// Creates the projects cache directory under the
  ///  root directory of our global cache directory - [cacheRootDir]
  ///
  /// The projec cache directory contains
  /// Link to script file
  /// Link to 'lib' directory of script file
  ///  or
  /// Lib directory if the script file doesn't have a lib dir.
  /// pubsec.yaml copy from script annotationf
  ///  or
  /// Link to scripts own pubspec.yaml file.
  /// hashes.yaml file.
  void createProject({bool skipPubGet = false, bool background = false}) {
    withLock(() {
      if (!exists(_virtualProjectPath)) {
        createDir(_virtualProjectPath);
        print('Created Virtual Project at ${_virtualProjectPath}');
      }

      _createScriptLink(script);
      _createLib();
      PubSpecManager(this).createVirtualPubSpec();
      if (skipPubGet) {
        print('Skipping pub get.');
      } else {
        if (background) {
          // we run the clean in the background
          // by running another copy of dshell.
          print('dshell clean started in background');
          // ('dshell clean ${script.path}' | 'echo > ${dirname(path)}/log').run;
          // 'dshell -v clean ${script.path}'.run;
          'dshell -v=/tmp/dshell.clean.log clean ${script.path}'
              .start(detached: true, runInShell: true);
        } else {
          print('Running pub get...');
          pubget();
        }
      }
    });
  }

  /// We need to create a link to the script
  /// from the project cache.
  void _createScriptLink(Script script) {
    if (!exists(_projectScriptLinkPath, followLinks: false)) {
      var link = Link(_projectScriptLinkPath);
      link.createSync(script.path);
    }
  }

  ///
  /// deletes the project cache directory and recreates it.
  void clean() {
    withLock(() {
      if (exists(_virtualProjectPath)) {
        if (Settings().isVerbose) {
          Settings().verbose('Deleting project path: $_virtualProjectPath');
        }
        deleteDir(_virtualProjectPath, recursive: true);
      }

      try {
        createProject();
      } on PubGetException {
        print(red("\ndshell clean failed due to the 'pub get' call failing."));
      }
    });
  }

  /// Causes a pub get to be run against the project.
  ///
  /// The projects cache must already exist and be
  /// in a consistent state.
  ///
  /// This is normally done when the project cache is first
  /// created and when a script's pubspec changes.
  void pubget() {
    withLock(() {
      var pubGet = PubGet(DartSdk(), this);
      pubGet.run(compileExecutables: false);
    });
  }

  // Create the cache lib as a real file or a link
  // as needed.
  // This may change on each run so need to able
  // to swap between a link and a dir.
  void _createLib() {
    // does the script have a lib directory
    if (Directory(scriptLib).existsSync()) {
      // does the cache have a lib
      if (Directory(projectCacheLib).existsSync()) {
        // ensure we have a link from cache to the scriptlib
        if (!FileSystemEntity.isLinkSync(projectCacheLib)) {
          // its not a link so we need to recreate it as a link
          // the script directory structure may have changed since
          // the last run.
          Directory(projectCacheLib).deleteSync();
          var link = Link(projectCacheLib);
          link.createSync(scriptLib);
        }
      } else {
        var link = Link(projectCacheLib);
        link.createSync(scriptLib);
      }
    } else {
      // no script lib so we need to create a real lib
      // directory in the project cache.
      if (!Directory(projectCacheLib).existsSync()) {
        // create the lib as it doesn't exist.
        Directory(projectCacheLib).createSync();
      } else {
        if (FileSystemEntity.isLinkSync(projectCacheLib)) {
          {
            // delete the link and create the required directory
            Directory(projectCacheLib).deleteSync();
            Directory(projectCacheLib).createSync();
          }
        }
        // it exists and is the correct type so no action required.
      }
    }

    // does the project cache lib link exist?
  }

  void get doctor {
    print('');
    print('');
    print('Script Details');
    colprint('Name', script.scriptname);
    colprint('Directory', privatePath(script.scriptDirectory));
    colprint('Virtual Project', privatePath(dirname(pubSpecPath)));
    print('');

    print('');
    print('Virtual pubspec.yaml');
    read(pubSpecPath).forEach((line) {
      print('  ${makeSafe(line)}');
    });

    print('');
    colprint('Dependencies', '');
    pubSpec().dependencies.forEach((d) => colprint(
        '  ${d.name}', '${d.isPath ? privatePath(d.path) : d.version}'));
  }

  String makeSafe(String line) {
    return line.replaceAll(HOME, '<HOME>');
  }

  void colprint(String label, String value, {int pad = 25}) {
    print('${label.padRight(pad)}: ${value}');
  }

  ///
  /// reads and returns the projects virtual pubspec
  /// and returns it.
  PubSpec pubSpec() {
    return PubSpecFile.fromFile(pubSpecPath);
  }

  /// We use this to allow a projects lock to be-reentrant
  /// A non-zero value means we have the lock.
  int _lockCount = 0;

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
  bool takeLock() {
    var taken = false;

    var lockFile = _lockFilePath;
    assert(!exists(lockFile));

    // can't come and add a lock whilst we are looking for
    // a lock.
    touch(lockFile, create: true);

    // check for other lock files
    var locks = find('*.$_lockSuffix', root: dirname(path)).toList();

    if (locks.length == 1) {
      // no other lock exists so we have taken a lock.
      taken = true;
    } else {
      // we have found another lock file so check if it is held be an running process
      for (var lock in locks) {
        var parts = basename(lock).split('.');
        if (parts.length != 4) {
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

        if (released) {
          taken = true;
        } else {
          throw LockException(
              'Unable to lock the Virtual Project ${truepath(path)} as it is currently held by ${ProcessHelper().getPIDName(lpid)}');
        }
      }
    }

    return taken;
  }

  void withLock(void Function() fn) {
    /// We must create the virtual project directory as we use
    /// its parent to store the lockfile.
    if (!exists(path)) {
      createDir(path, recursive: true);
    }
    try {
      if (_lockCount > 0 || takeLock()) {
        _lockCount++;
        fn();
      }
    } finally {
      if (_lockCount > 0) {
        _lockCount--;
        if (_lockCount == 0) delete(_lockFilePath);
      }
    }
  }

  String get _lockSuffix => '${basename(path).replaceAll('.', '_')}.clean.lock';
  String get _lockFilePath {
    // lock file is in the directory above the project
    // as during cleaning we delete the project directory.
    return join(dirname(path), '$pid.${_lockSuffix}');
  }
}

class LockException implements Exception {
  String message;
  LockException(this.message);

  @override
  String toString() {
    return message;
  }
}
