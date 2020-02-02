import 'dart:io';
import 'package:dshell/src/util/ansi_color.dart';

import '../functions/is.dart';
import '../pubspec/pubspec.dart';
import '../pubspec/pubspec_file.dart';
import '../pubspec/pubspec_manager.dart';
import 'pub_get.dart';
import '../util/log.dart';
import 'package:path/path.dart' as p;

import '../settings.dart';
import 'dart_sdk.dart';
import 'script.dart';
import '../util/file_helper.dart';

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
    _virtualProjectPath = p.join(cacheRootPath,
        script.scriptDirectory.substring(1), script.basename + PROJECT_DIR);

    _projectLibPath = p.join(_virtualProjectPath, 'lib');
    _projectScriptLinkPath = p.join(_virtualProjectPath, script.scriptname);
    _scriptLibPath = p.join(script.scriptDirectory, 'lib');
  }

  String get scriptLib => _scriptLibPath;
  String get projectCacheLib => _projectLibPath;

  /// The  absolute path to the
  /// virtual project's project directory.
  /// This is this is essentially:
  /// join(Settings().dshellCache, dirname(script), PROJECT_DIR)
  ///
  String get path => _virtualProjectPath;

  String get pubSpecPath => p.join(_virtualProjectPath, 'pubspec.yaml');

  /// Creates the projects cache directory under the
  ///  root directory of our global cache directory - [cacheRootDir]
  ///
  /// The projec cache directory contains
  /// Link to script file
  /// Link to 'lib' directory of script file
  ///  or
  /// Lib directory if the script file doesn't have a lib dir.
  /// pubsec.yaml copy from script annotation
  ///  or
  /// Link to scripts own pubspec.yaml file.
  /// hashes.yaml file.
  void createProject({bool skipPubGet = false}) {
    if (!createDir(_virtualProjectPath, 'project cache')) {
      print('Created Virtual Project at ${_virtualProjectPath}');
    }

    // HashesYaml.create(_virtualProjectPath);

    _createScriptLink(script);
    _createLib();
    PubSpecManager(this).createVirtualPubSpec();
    if (skipPubGet) {
      print('Skipping pub get.');
    } else {
      print('Running pub get...');
      pubget();
    }
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
    if (exists(_virtualProjectPath)) {
      if (Settings().isVerbose) {
        Settings().verbose('Deleting project path: $_virtualProjectPath');
      }
      File(_virtualProjectPath).deleteSync(recursive: true);
    }

    try {
      createProject();
    } on PubGetException {
      print(red("\ndshell clean failed due to the 'pub get' call failing."));
    }
  }

  /// Causes a pub get to be run against the project.
  ///
  /// The projects cache must already exist and be
  /// in a consistent state.
  ///
  /// This is normally done when the project cache is first
  /// created and when a script's pubspec changes.
  void pubget() {
    var pubGet = PubGet(DartSdk(), this);
    pubGet.run();
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

  ///
  /// reads and returns the projects virtual pubspec
  /// and returns it.
  PubSpec pubSpec() {
    return PubSpecFile.fromFile(pubSpecPath);
  }
}
