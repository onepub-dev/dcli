import "dart:io";
import 'package:dshell/script/project_cache.dart';
import 'package:dshell/script/pub_get.dart';
import 'package:path/path.dart' as p;

import 'dart_sdk.dart';
import 'hashes_yaml.dart';
import 'log.dart';
import 'pubspec.dart';
import 'script.dart';
import 'package:dshell/util/file_helper.dart';

/// Creates project directory structure
class Project {
  final Script script;

  // A temporary directory where create
  // the virtual project.
  final String projectCacheDir;

  HashesYaml hashes;

  /// Returns a [project] instance for the given
  /// script.
  Project(this.projectCacheDir, this.script);

  String get scriptLib => p.join(script.scriptDirectory, "lib");
  String get projectCacheLib => p.join(projectCacheDir, "lib");

  /// The project cachePath REALTIVE to the project cache directory.
  /// The projects caches location is:
  ///  <cache-path>/<path to real script><script-name>.dir
  String get relativeCachePath =>
      p.join(script.scriptDirectory.substring(1), "${script.scriptname}.dir");

  /// The absolute version of the projects cache path
  String absoluteCachePath(String rootCacheDir) =>
      p.join(rootCacheDir, relativeCachePath);

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
  void createCache(String rootCacheDir) {
    String projectCache = absoluteCachePath(rootCacheDir);

    if (!createDir(projectCache, "project cache")) {
      Log.error(
          'Created roject cache path at ${projectCacheDir}', LogLevel.verbose);
    }

    hashes = HashesYaml(projectCacheDir);

    _createScriptLink(script);
    _createLib();
    _createPubSpec(script);
  }

  /// We need to create a link to the script
  /// from the project cache.
  void _createScriptLink(Script script) {
    Link link = Link(script.scriptPath);
    link.createSync(projectCacheDir);
  }

  void _createPubSpec(Script script) {
    PubSpec pubspec = PubSpec(script);
    pubspec.saveToFile(this.absoluteCachePath(projectCacheDir));
  }

  ///
  /// deletes the project cache directory and recreates it.
  void clean() {
    String rootCacheDir = ProjectCache().cachePath;
    File(absoluteCachePath(rootCacheDir)).deleteSync(recursive: true);

    createCache(rootCacheDir);
  }

  /// Causes a pub get to be run against the project.
  ///
  /// The projects cache must already exist and be
  /// in a consistent state.
  ///
  /// This is normally done when the project cache is first
  /// created and when a script's pubspec changes.
  void pubget() {
    PubGet pubGet = PubGet(DartSdk(), this);
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
          Link link = Link(projectCacheLib);
          link.createSync(scriptLib);
        }
      } else {
        Link link = Link(projectCacheLib);
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
}
