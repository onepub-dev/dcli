/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

library dart_project;

import 'dart:io' as io;

import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:pubspec_manager/pubspec_manager.dart';
// Here simply to avoid conflicts with the old NamedLocks
import 'package:runtime_named_locks/runtime_named_locks.dart';

import '../../dcli.dart' hide NamedLock;
import '../../posix.dart';
import '../version/version.g.dart';
import 'pub_get.dart';
import 'pub_upgrade.dart';

/// Used to managed a Dart project.
///
/// Provides access to a Dart Project's resources such as
/// of a pubspec.yaml, dart files, directory structure
/// as well as performing some basic operations on the
/// Dart Project.
///
part 'dart_project_creator.dart';

class DartProject {
  /// Create a dart project on the file system at
  /// [pathTo] from the template named [templateName].
  factory DartProject.create(
      {required String pathTo, required String templateName}) {
    _createProject(pathTo, templateName);
    return DartProject.fromPath(pathTo, search: false);
  }

  /// Loads the project from the dart pub cache
  /// named [name] for the version [version].
  /// e.g. ~/.pub-cache/hosted/pub.dartlang.org/dswitch-4.0.1
  DartProject.fromCache(String name, String version) {
    _pathToProjectRoot = truepath(PubCache().pathToPackage(name, version));
  }

  /// Load a dart project from the given directory.
  ///
  /// We search up the tree starting from [pathToSearchFrom]
  /// until we find a pubspec.yaml and that becomes the
  /// project root directory.
  /// If we don't find a pubspec.yaml then [pathToSearchFrom] is returned
  /// as the project root.
  /// If you want to test whether you are in a Dart project then use
  /// [findProject].
  /// Set [search] to false if you don't want to search up the
  /// directory tree for a pubspec.yaml.
  DartProject.fromPath(String pathToSearchFrom, {bool search = true}) {
    _pathToProjectRoot =
        _findProject(pathToSearchFrom, search: search) ?? pathToSearchFrom;
    verbose(() => 'DartProject.fromPath: $pathToProjectRoot');
  }

  late String _pathToProjectRoot;
  String? _pathToPubSpec;

  static DartProject? _current;

  /// If you
  @Deprecated('Use DartProject.self')
  static DartProject get current => self;

  /// Looks for a pubspec.yaml and if found returns a [DartProject].
  ///
  /// If [search] is true then it will search from [pathToSearchFrom]
  /// up the tree.
  static DartProject? findProject(String pathToSearchFrom,
      {bool search = true}) {
    final path = _findProject(pathToSearchFrom, search: search);

    return path == null ? null : DartProject.fromPath(path);
  }

  static String? _findProject(String pathToSearchFrom, {bool search = true}) {
    String? pathToProjectRoot;
    if (search) {
      pathToProjectRoot = _findProjectRoot(pathToSearchFrom);
    } else {
      if (exists(join(pathToSearchFrom, 'pubspec.yaml'))) {
        pathToProjectRoot = pathToSearchFrom;
      }
    }
    if (pathToProjectRoot != null) {
      pathToProjectRoot = truepath(pathToProjectRoot);
    }
    return pathToProjectRoot;
  }

  /// Returns the instance of the currently running DartProject.
  ///
  /// If you call this method from a non-compiled script
  /// then we start the search from the scripts directory
  /// and search up the directory tree.
  ///
  /// If you call this method from a compiled script
  /// then we will return the current working directory
  /// as there is no 'project root' for a compiled script.
  ///
  /// If you are looking to load the project from a directory
  /// then use [DartProject.fromPath()]
  ///
  // ignore: prefer_constructors_over_static_methods
  static DartProject get self {
    if (io.Platform.packageConfig != null) {
      /// When running as a unit test we can't use DartScript.self
      /// as it returns the the test runner.
      /// The packageConfig is available if passed (which unit tests do)
      /// and when passed is probably the most relable means of
      /// determining the project directory.
      return _current ??= DartProject.fromPath(
          dirname(dirname(Uri.parse(io.Platform.packageConfig!).path)));
    }
    final script = DartScript.self;
    var startFrom = '.';
    if (!script.isCompiled && !script.isPubGlobalActivated) {
      startFrom = script.pathToScript;
    }
    return _current ??= DartProject.fromPath(startFrom);
  }

  ///
  /// reads and returns the project's virtual pubspec
  /// and returns it.
  PubSpec get pubSpec => PubSpec.loadFromPath(pathToPubSpec);

  /// Absolute path to the project's root diretory.
  String get pathToProjectRoot => _pathToProjectRoot;

  /// Absolute path to the project's '.dart_tool' directory.
  String get pathToDartToolDir => truepath(_pathToProjectRoot, '.dart_tool');

  /// Absolute path to the project's '.dart_tool/package_config.json' directory.
  String get pathToDartToolPackageConfig =>
      truepath(pathToDartToolDir, 'package_config.json');

  /// Absolute path to the project's 'bin' directory.
  String get pathToBinDir => truepath(_pathToProjectRoot, 'bin');

  /// Absolute path to the project's 'example' directory.
  String get pathToExampleDir => truepath(_pathToProjectRoot, 'example');

  /// Absolute path to the project's 'lib' directory.
  String get pathToLibDir => truepath(_pathToProjectRoot, 'lib');

  /// Absolute path to the project's 'lib/src' directory.
  String get pathToLibSrcDir => truepath(pathToLibDir, 'src');

  /// Absolute path to the project's 'test' directory.
  String get pathToTestDir => truepath(_pathToProjectRoot, 'test');

  /// Absolute path to the project's 'tool' directory.
  String get pathToToolDir => truepath(_pathToProjectRoot, 'tool');

  /// Absolute pathto the project's analysis_options.yaml
  String get pathToAnalysisOptions =>
      _pathToPubSpec ??= join(_pathToProjectRoot, 'analysis_options.yaml');

  /// Absolute pathto the project's pubspec.yaml
  String get pathToPubSpec =>
      _pathToPubSpec ??= join(_pathToProjectRoot, 'pubspec.yaml');

  /// Absolute pathto the project's pubspec.lock
  String get pathToPubSpecLock =>
      _pathToPubSpec ??= join(_pathToProjectRoot, 'pubspec.lock');

  /// Used by the dcli doctor command to print
  /// out the DartProjects details.
  void doctor() {
    _colprint('Pubspec Path', privatePath(pathToPubSpec));
    print('');

    print('');
    print('pubspec.yaml');
    read(pathToPubSpec).forEach((line) {
      print('  ${_makeSafe(line)}');
    });

    print('');
    _colprint('Dependencies', '');
    for (final dependency in pubSpec.dependencies.list) {
      _colprint(dependency.name, dependency.toString());
    }
  }

  void _colprint(String label, String value, {int pad = 25}) {
    print('${label.padRight(pad)}: $value');
  }

  String _makeSafe(String line) =>
      HOME == '.' ? HOME : line.replaceAll(HOME, '<HOME>');

  /// Searches up the directory tree from [pathToSearchFrom]
  /// for a dart package by looking for a pubspec.yaml.
  /// If no pubspec.yaml if found we return null.
  static String? _findProjectRoot(String pathToSearchFrom) {
    var current = truepath(pathToSearchFrom);

    final root = rootPrefix(current);

    // traverse up the directory to find if we are in a traditional directory.
    while (current != root) {
      if (exists(join(current, 'pubspec.yaml'))) {
        return current;
      }
      current = dirname(current);
    }

    return null;
  }

  static const _lockName = 'dcli.script.dart.project.lock';

  /// Prepare the project so it can be run.
  /// This essentially means that we run pub get
  /// however if the project hasn't been initialised
  /// then we initialise the project as well.
  /// if [background] is set to true then we
  /// run the build as a background process.
  /// [background] defaults to false.
  ///
  /// If [upgrade] is true then a pub upgrade is ran rather than
  /// pub get.
  ///
  void warmup({bool background = false, bool upgrade = false}) {
    NamedLock.guard(
      name: _lockName,
      execution: ExecutionCall<void, PubGetException>(
        callable: () {
          try {
            if (background) {
              // we run the clean in the background
              // by running another copy of dcli.
              print('DCli warmup started in the background.');
              '${DCliPaths().dcliName} '
                      '''-v=${join(io.Directory.systemTemp.path, 'dcli.warmup.log')}'''
                      ' warmup $pathToProjectRoot'
                  .start(
                detached: true,
                runInShell: true,
                extensionSearch: false,
              );
            } else {
              // print(orange('Running pub get...'));
              if (upgrade) {
                _pubupgrade();
              } else {
                _pubget();
              }
            }
          } on PubGetException {
            print(
                red("\ndcli warmup failed due to the 'pub get' call failing."));
          }
        },
      ),
      waiting: 'Waiting for warmup to complete...',
    );
  }

  /// Removes any of the dart build artifacts so you have a clean directory.
  /// We do this recursively so all subdirectories will also be purged.
  ///
  /// Deletes:
  /// pubspec.lock
  /// ./packages
  /// .dart_tools
  ///
  /// Any exes for scripts in the directory.
  void clean() {
    NamedLock.guard(
      name: _lockName,
      execution: ExecutionCall<void, PubGetException>(
        callable: () {
          try {
            find(
              '.packages',
              types: [Find.file],
              workingDirectory: pathToProjectRoot,
            ).forEach(delete);

            /// we cant delete directories whilst recusively scanning them.
            final toBeDeleted = <String>[];
            find(
              '.dart_tool',
              types: [Find.directory],
              workingDirectory: pathToProjectRoot,
            ).forEach(toBeDeleted.add);

            _deleteDirs(toBeDeleted);

            find('pubspec.lock', workingDirectory: pathToProjectRoot)
                .forEach(delete);

            find('*.dart', workingDirectory: pathToProjectRoot)
                .forEach((scriptPath) {
              final script = DartScript.fromFile(scriptPath);
              if (exists(script.pathToExe)) {
                delete(script.pathToExe);
              }
            });
          } on PubGetException {
            print(
                red("\ndcli clean failed due to the 'pub get' call failing."));
          }
        },
      ),
      waiting: 'Waiting for clean to complete...',
    );
  }

  /// Compiles all dart scripts in the project.
  /// If you set [install] to true then each compiled script
  /// is added to your PATH by copying it into ~/.dcli/bin.
  /// [install] defaults to false.
  ///
  /// The [overwrite] flag allows the [compile] to install the
  /// compiled script even if one of the same name exists in `/.dcli/bin
  /// [overwrite] defaults to false.
  ///
  void compile({bool install = false, bool overwrite = false}) {
    NamedLock.guard(
      name: _lockName,
      execution: ExecutionCall<void, PubGetException>(callable: () {
        find('*.dart', workingDirectory: pathToProjectRoot).forEach((file) =>
            DartScript.fromFile(file)
                .compile(install: install, overwrite: overwrite));
      }),
      waiting: 'Waiting for compile to complete...',
    );
  }

  /// Causes a pub get to be run against the project.
  ///
  /// The projects cache must already exist and be
  /// in a consistent state.
  ///
  /// This is normally done when the project cache is first
  /// created and when a script's pubspec changes.
  void _pubget() {
    NamedLock.guard(
      name: _lockName,
      execution: ExecutionCall<void, PubGetException>(callable: () {
        final pubGet = PubGet(this);
        if (Shell.current.isSudo) {
          /// bugger we just screwed the cache permissions so lets fix them.
          'chmod -R ${env['USER']}:${env['USER']} ${PubCache().pathTo}'.run;
          throw DartProjectException(
              'You must compile your script before running it under sudo');
        }
        pubGet.run(compileExecutables: false);
      }),
    );
  }

  /// Causes a pub upgrade to be run against the project.
  ///
  /// The projects cache must already exist and be
  /// in a consistent state.
  ///
  /// This is normally done when the project cache is first
  /// created and when a script's pubspec changes.
  void _pubupgrade() {
    // Refactor with named lock guard
    NamedLock.guard(
      name: _lockName,
      execution: ExecutionCall<void, PubGetException>(callable: () {
        final pubUpgrade = PubUpgrade(this);
        if (Shell.current.isSudo) {
          /// bugger we just screwed the cache permissions so lets fix them.
          'chmod -R ${env['USER']}:${env['USER']} ${PubCache().pathTo}'.run;
          throw DartProjectException(
              'You must compile your script before running it under sudo');
        }
        pubUpgrade.run(compileExecutables: false);
      }),
    );
  }

  // TODO(bsutton): this is still risky as pub get does a test to see if
  // the versions have changed.
  /// there is a 'generated' date stamp in the .json file which
  ///  might be more definitive.
  /// Returns true if the project is in state when any of its
  /// scripts can be run.
  ///
  /// This essentially means that pub get has been ran.
  ///
  /// We have:
  /// * pubspec.yaml
  /// * pubspec.lock
  /// *
  ///
  bool get isReadyToRun =>
      hasPubSpec && !DartSdk().isPubGetRequired(pathToProjectRoot);

  /// Returns true if this project is a flutter projects.
  ///
  /// We check to see if flutter is a project dependency.
  bool get isFlutterProject => pubSpec.dependencies.exists('flutter');

  /// Returns true if the project contains a pubspec.yaml.
  bool get hasPubSpec => exists(join(pathToProjectRoot, 'pubspec.yaml'));

  /// Returns true if the project has an 'analysis_options.yaml' file.
  bool get hasAnalysisOptions =>
      exists(join(pathToProjectRoot, 'analysis_options.yaml'));

  void _deleteDirs(List<String> toBeDeleted) {
    for (final dir in toBeDeleted) {
      if (exists(dir)) {
        deleteDir(dir);
      }
    }
  }

// /// Prepares the project by creating a pubspec.yaml and
// /// the analysis_options.yaml file.
// void initFiles() {
//   if (!hasPubSpec) {
//     _createPubspecFromTemplate(
//         pathToProjectRoot: pathToProjectRoot, pathToPubSpec:
// pathToPubSpec);
//   }

//   if (!hasAnalysisOptions) {
//     /// add pedantic to the project
//     _createAnalysisOptionsFromTemplate(
//         pathToProjectRoot: pathToProjectRoot, pathToPubSpec:
// pathToPubSpec);
//   }
// }

//   /// Creates a project located at [pathToProject] from the
//passed [templatePath].
//   /// When the user runs 'dcli create <project>'
//   void _createFromTemplate({
//     required String templatePath,
//     required String pathToProject,
//   }) {
//     verbose(() => '_createFromTemplate $templatePath $pathToProject');
//     if (!exists(templatePath)) {
//       throw TemplateNotFoundException(templatePath);
//     }
//     copy(templatePath, pathToProject);

//     replace(pathToProject, 'scriptname', basename(pathToProject));

//     if (!hasPubSpec) {
//       _createPubspecFromTemplate(
//           pathToProjectRoot: pathToProjectRoot,
// pathToPubSpec: pathToPubSpec);
//     }
//     if (!hasAnalysisOptions) {
//       _createAnalysisOptionsFromTemplate(
//           pathToProjectRoot: pathToProjectRoot,
// pathToPubSpec: pathToPubSpec);
//     }
//   }
// }
}

/// Exception for issues with DartProjects.
class DartProjectException extends DCliException {
  /// Create a DartProject related exceptions
  DartProjectException(super.message);
}

/// The requested DCli template does not exists.
class TemplateNotFoundException extends DCliException {
  /// The requested DCli template does not exists.
  TemplateNotFoundException(String pathTo)
      : super('The template $pathTo does not exist.');
}
