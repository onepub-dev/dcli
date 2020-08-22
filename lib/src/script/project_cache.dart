import 'package:file/file.dart';

import '../../dcli.dart';
import '../settings.dart';

import 'script.dart';
import 'virtual_project.dart';

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
  // located dcli settings directory
  // which is normally .dcli

  static ProjectCache _self;

  ProjectCache._internal() {
    _self = this;
  }

  ///
  factory ProjectCache() {
    _self ??= ProjectCache._internal();
    _self.initCache();

    return _self;
  }

  ///
  /// Checks if the dscript cache exists
  /// and if not creates it.
  void initCache() {
    if (!exists(Settings().dcliCachePath)) {
      createDir(Settings().dcliCachePath);
    }
  }

  /// If the [cleanall] command is issued
  /// we will clean out the project cache
  /// for all scripts.
  void cleanAll() {
    print('Cleaning project cache ${Settings().dcliCachePath}');

    try {
      find('*.project',
          root: Settings().dcliCachePath,
          recursive: true,
          types: [FileSystemEntityType.directory]).forEach((projectPath) {
        var scriptPath = join(
            rootPath,
            withoutExtension(
                '${relative(projectPath, from: Settings().dcliCachePath)}.dart'));

        deleteDir(projectPath, recursive: true);

        if (exists(scriptPath)) {
          print('');
          print(green('Cleaning $scriptPath'));
          var project = VirtualProject.create(Script.fromFile(scriptPath));
          project.build();
        } else {
          print('Removed obsolete cache for $scriptPath');
        }
      });
    } finally {}
  }
}
