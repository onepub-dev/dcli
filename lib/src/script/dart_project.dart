import 'dart:io';

import 'package:dcli/src/functions/find.dart';
import 'package:dcli/src/pubspec/pubspec.dart';
import 'package:path/path.dart';

import '../../dcli.dart';
import 'pub_get.dart';

/// Encapsulates the idea of a dart project which is made up
/// of a pubspec.yaml, dart files ....

class DartProject {
  String _pathToProjectRoot;
  String _pathToPubSpec;

  /// Load a dart project from the given directory.
  /// We search up the tree starting from [pathToSearchFrom]
  /// until we find a pubspec.yaml and that becomes the
  /// project root. directory.
  DartProject.fromPath(String pathToSearchFrom, {bool search = false}) {
    if (search) {
      _pathToProjectRoot = _findProjectRoot(pathToSearchFrom);
    } else {
      _pathToProjectRoot = pathToSearchFrom;
    }
    _pathToProjectRoot = truepath(_pathToProjectRoot);
  }

  static DartProject _current;

  /// Returns the instance of the currently running DartProject.
  ///
  /// If you call this method from a non-compiled script
  /// then we start the search from the scripts directory
  /// and search up the directory tree.
  ///
  /// If you call this method from a compiled script
  /// then we will return the current working directory
  /// as there is no 'project root' for a compiled script.
  // ignore: prefer_constructors_over_static_methods
  static DartProject get current {
    final script = Script.current;
    var startFrom = '.';
    if (!script.isCompiled) {
      startFrom = script.pathToScript;
    }
    return _current ??= DartProject.fromPath(startFrom, search: true);
  }

  ///
  /// reads and returns the project's virtual pubspec
  /// and returns it.
  PubSpec get pubSpec {
    return PubSpec.fromFile(pathToPubSpec);
  }

  /// Returns the path to the project's root diretory.
  String get pathToProjectRoot => _pathToProjectRoot;

  // Returns the pat to the project's pubspec.yaml
  String get pathToPubSpec =>
      _pathToPubSpec ??= join(_pathToProjectRoot, 'pubspec.yaml');

  // Used by the dcli doctor command to print
  // out the DartProjects details.
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
    for (final name in pubSpec.dependencies.keys) {
      _colprint(name, pubSpec.dependencies[name].rehydrate());
    }
  }

  void _colprint(String label, String value, {int pad = 25}) {
    print('${label.padRight(pad)}: $value');
  }

  String _makeSafe(String line) {
    return line.replaceAll(HOME, '<HOME>');
  }

  String _findProjectRoot(String pathToSearchFrom) {
    var current = truepath(pathToSearchFrom);

    final root = rootPrefix(current);

    // traverse up the directory to find if we are in a traditional directory.
    while (current != root) {
      if (exists(join(current, 'pubspec.yaml'))) {
        return current;
      }
      current = dirname(current);
    }

    /// no pubspec.yaml found so the project root is the passed directory.
    return pathToSearchFrom;
  }

  NamedLock __lock;
  static const _lockName = 'script.lock';

  NamedLock get _lock =>
      __lock ??= NamedLock(name: _lockName, lockPath: pathToProjectRoot);

  ///
  /// Prepare the project so it can be run.
  /// This essentially means that we run pub get
  /// however if the project hasn't been initialised
  /// then we initialise the project as well.
  /// if [background] is set to true then we
  /// run the build as a background process.
  /// [background] defaults to false.
  ///
  void warmup({bool background = false}) {
    _lock.withLock(() {
      try {
        if (background) {
          // we run the clean in the background
          // by running another copy of dcli.
          print('DCli warmup started in the background.');
          '${DCliPaths().dcliName} -v=${join(Directory.systemTemp.path, 'dcli.warmup.log')} warmup $pathToProjectRoot'
              .start(detached: true, runInShell: true);
        } else {
          // print(orange('Running pub get...'));
          _pubget();
        }
      } on PubGetException {
        print(red("\ndcli warmup failed due to the 'pub get' call failing."));
      }
    }, waiting: 'Waiting for warmup to complete...');
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
    _lock.withLock(() {
      find(
        '.packages',
        types: [Find.file],
        root: pathToProjectRoot,
      ).forEach((file) => delete(file));
      find(
        '.dart_tool',
        types: [Find.directory],
        root: pathToProjectRoot,
      ).forEach((file) => deleteDir(file));
      find('pubspec.lock', root: pathToProjectRoot)
          .forEach((file) => delete(file));

      find('*.dart', root: pathToProjectRoot).forEach((scriptPath) {
        final script = Script.fromFile(scriptPath);
        if (exists(script.pathToExe)) {
          delete(script.pathToExe);
        }
      });
    }, waiting: 'Waiting for clean to complete...');
  }

  /// Compiles all dart scripts in the project.
  /// If you set[install] to true then each compiled script
  /// is added to your PATH by copying it into ~/.dcli/bin.
  /// [install] defaults to false.
  ///
  /// The [overwrite] flag allows the [compile] to install the
  /// compiled script even if one of the same name exists in `/.dcli/bin
  /// [overwrite] defaults to false.
  ///
  void compile({bool install = false, bool overwrite = false}) {
    find('*.dart', root: pathToProjectRoot).forEach((file) =>
        Script.fromFile(file).compile(install: install, overwrite: overwrite));
  }

  /// Causes a pub get to be run against the project.
  ///
  /// The projects cache must already exist and be
  /// in a consistent state.
  ///
  /// This is normally done when the project cache is first
  /// created and when a script's pubspec changes.
  void _pubget() {
    NamedLock(
      name: _lockName,
      lockPath: pathToProjectRoot,
    ).withLock(() {
      final pubGet = PubGet(this);
      if (Shell.current.isSudo) {
        /// bugger we just screwed the cache permissions so lets fix them.
//         'chmod -R ${env['USER']}:${env['USER']} ${PubCache().pathTo}'.run;

        printerr('You must compile your script before running it under sudo');

        /// TODO: should this be a throw?
        exit(1);
      }
      pubGet.run(compileExecutables: false);
    });
  }

  /// Returns true if the project is in state when any of its scripts can be run.
  ///
  /// This essentially means that pub get has been ran.
  ///
  /// We have:
  /// * pubspec.yaml
  /// * pubspec.lock
  /// *
  bool get isReadyToRun {
    // TODO: this is still risky as pub get does a test to see if the versions have changed.
    // we could improve this by checking that the .lock files date is after the .yamls date.
    /// there is a 'generated' date stamp in the .json file which might be more definitive.
    return exists(
            join(pathToProjectRoot, '.dart_tool', 'package_config.json')) &&
        exists(join(pathToProjectRoot, 'pubspec.lock')) &&
        hasPubSpec;
  }

  /// Returns true if the project contains a pubspec.yaml.
  bool get hasPubSpec => exists(join(pathToProjectRoot, 'pubspec.yaml'));

  /// Returs true if the project has an 'analyssi_options.yaml' file.
  bool get hasAnalysisOptions =>
      exists(join(pathToProjectRoot, 'analysis_options.yaml'));

  /// Prepares the project by creating a pubspec.yaml and
  /// the analysis_options.yaml file.
  void initFiles() {
    if (!hasPubSpec) {
      _createPubspecFromTemplate(showWarnings: false);
    }

    if (!hasAnalysisOptions) {
      /// add pedantic to the project
      _createAnalysisOptionsFromTemplate(showWarnings: false);
    }
  }

  /// Creates a script located at [pathToScript] from the passed [templatePath].
  /// When the user runs 'dcli create <script>'
  void _createFromTemplate({String templatePath, String pathToScript}) {
    copy(templatePath, pathToScript);

    replace(pathToScript, '%dcliName%', DCliPaths().dcliName);
    replace(pathToScript, '%scriptname%', basename(pathToScript));

    if (!hasPubSpec) _createPubspecFromTemplate(showWarnings: false);
    if (!hasAnalysisOptions) {
      _createAnalysisOptionsFromTemplate(showWarnings: false);
    }
  }

  void _createAnalysisOptionsFromTemplate({bool showWarnings}) {
    /// add pedantic to the project

    final analysisPath = join(pathToProjectRoot, 'analysis_options.yaml');
    if (!exists(analysisPath)) {
      if (showWarnings) {
        print(orange('Creating missing analysis_options.yaml.'));
      }

      copy(join(Settings().pathToTemplate, 'analysis_options.yaml'),
          analysisPath);
    }
  }

  void _createPubspecFromTemplate({bool showWarnings}) {
    if (showWarnings) {
      print(orange('Creating missing pubspec.yaml.'));
    }
    // no pubspec.yaml in scope so lets create one.

    copy(join(Settings().pathToTemplate, 'pubspec.yaml.template'),
        pathToPubSpec);
    replace(pathToPubSpec, '%scriptname%',
        _replaceInvalidCharactersForName(basename(pathToProjectRoot)));
  }

  /// Creates a script using the default template (basic.dart)
  Script createScript(String pathToScript,
      {String templateName = 'basic.dart'}) {
    _createFromTemplate(
      templatePath: join(Settings().pathToTemplate, templateName),
      pathToScript: pathToScript,
    );

    return Script.fromFile(pathToScript, project: this);
  }

  /// The name used in the pubspec.yaml must come from the character set [a-z0-9_]
  /// so wer replace any invalid character with an '_'.
  String _replaceInvalidCharactersForName(String proposedName) {
    return proposedName.replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');
  }
}
