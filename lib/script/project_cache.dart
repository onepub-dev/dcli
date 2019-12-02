import 'dart:io';

import 'package:dshell/util/file_helper.dart';
import 'package:dshell/util/log.dart';
import 'package:dshell/util/waitForEx.dart';
import 'package:path/path.dart' as p;

import '../settings.dart';
import 'std_log.dart';
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
  // located dshell settings directory
  // which is normally .dshell

  static const String CACHE_DIR = "cache";
  static ProjectCache _self;

  // absolute path to the root of the cache.
  String _cacheRootPath;

  ProjectCache._internal() {
    _self = this;

    // set the absolute path of the cache root.
    _cacheRootPath = p.join(Settings().configRootPath, CACHE_DIR);
  }

  factory ProjectCache() {
    if (_self == null) {
      _self = ProjectCache._internal();
    }
    _self.initCache();

    return _self;
  }

  String get path => _cacheRootPath;

  // Creates a project ready to run for
  // the given script.
  // If the project already exists then it will
  // be refreshed if required.
  VirtualProject createProject(Script script) {
    VirtualProject project = VirtualProject(_cacheRootPath, script);
    project.createProject();
    return project;
  }

  ///
  /// Checks if the dscript cache exists
  /// and if not creates it.
  void initCache() {
    createDir(_cacheRootPath, "cache");
  }

  /// If the [cleanall] command issued
  /// we will clean out the project cache
  /// for all scripts.
  void cleanAll() {
    Log().d(
      'Cleaning project cache ${_cacheRootPath}',
    );
    try {
      waitForEx(Directory(_cacheRootPath).delete(recursive: true));
    } finally {}
  }
}
