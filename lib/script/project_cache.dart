import 'dart:cli';
import 'dart:io';

import 'package:dshell/util/file_helper.dart';
import 'package:path/path.dart' as p;

import 'log.dart';
import 'project.dart';
import 'script.dart';

///
/// The aim of the cache is to speed up launch times
/// by keeping a cache of the pubspec and lib
/// directories so we don't need to recreate these
/// each time we launch.
///
/// The project cache contains a full copy of the
/// project in the form:
///
/// ~.dscript-cache/<path to script>/<script-name>.dir
///   .hashes.yaml
///     - pubspec-hash
///     - script-hash
///   link to: <script-name>.dart
///   pubspec.dart
///   link to : lib
///     - contents of lib.
///
/// If the script dir doesn't have a lib then
/// we create an empty lib directory in the cache project folder.
///
/// On startup we do a hash of the pubspec, script
/// and lib directories.
/// If the .hashes file doesn't exist it is created
/// along with a full rebuld of the project in to the cache.
/// If the .hashes file exists then a comparison is done of
/// each of the following hashes
///
/// pubspec - if no changes that pub get is not run.
/// script-last-modified - if the last modified has not change
///  then the script is not updated.
///  if last modified has changed, then the script is copied to
///  the project folder.
class ProjectCache {
  // Name of the cache directory which is normally
  // located under the users home directory.
  static const String cacheDir = ".dscript-cache";
  static ProjectCache _self;

  // absolute path to the cache.
  String _cachePath;

  ProjectCache._internal() {
    _self = this;
  }

  factory ProjectCache() {
    if (_self == null) {
      _self = ProjectCache._internal();
    }
    _self.initCache();

    return _self;
  }

  // Creates a project ready to run for
  // the given script
  Project createProject(Script script) {
    Project project = Project(cachePath, script);
    project.createCache(cachePath);
    return project;
  }

  ///
  /// Checks if the dscript cache exists
  /// and if not creates it.
  void initCache() {
    createDir(cachePath, "cache");
  }

  /// returns the absolute cache path which is located at:
  /// ~.dscript-cache
  String get cachePath {
    if (_cachePath == null) {
      Map<String, String> env = Platform.environment;
      String home = env["HOME"];
      _cachePath = p.canonicalize(p.join(home, cacheDir));
    }

    return _cachePath;
  }

  /// If the [cleanall] command issued
  /// we will clean out the project cache
  /// for all scripts.
  void cleanAll() {
    Log.error('Cleaning project cache ${cachePath}', LogLevel.verbose);
    try {
      waitFor(Directory(cachePath).delete(recursive: true));
    } finally {}
  }

  /// Returns the [project]s absolute path in the cache.
  ///
  /// Note: we need to include the script name as a directory
  /// may have several scripts each with their own pubspec.
  /// ~.dscript-cache
  String cacheLocation(Project project) {
    // we remove the leading slash of the absolute scriptDirectory
    // so it becomes a subdirectory under [cachePath]
    return p.join(cachePath, project.relativeCachePath);
  }
}
