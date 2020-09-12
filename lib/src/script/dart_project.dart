import 'dart:io';

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
    pubSpec.dependencies.forEach((d) => _colprint(d.name, '${d.rehydrate()}'));
  }

  void _colprint(String label, String value, {int pad = 25}) {
    print('${label.padRight(pad)}: $value');
  }

  String _makeSafe(String line) {
    return line.replaceAll(HOME, '<HOME>');
  }

  String _findProjectRoot(String pathToSearchFrom) {
    var current = absolute(pathToSearchFrom);

    var root = rootPrefix(current);

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

  NamedLock get _lock {
    __lock ??= NamedLock(name: '.script.lock', lockPath: pathToProjectRoot);
    return __lock;
  }

  ///
  /// Clean the project.
  /// This essentially means that we run pub get
  /// however if the project hasn't been initialised
  /// then we initialise the project as well.
  /// if [background] is set to true then we
  /// run the build as a background process.
  /// [background] defaults to [false]
  ///
  void clean({bool background = false}) {
    _lock.withLock(() {
      try {
        if (background) {
          // we run the clean in the background
          // by running another copy of dcli.
          print('DCli clean started in the background.');
          '${DCliPaths().dcliName} -v=${join(Directory.systemTemp.path, 'dcli.clean.log')} clean ${pathToProjectRoot}'
              .start(detached: true, runInShell: true);
        } else {
          // print(orange('Running pub get...'));
          _pubget();
        }
      } on PubGetException {
        print(red("\ndcli clean failed due to the 'pub get' call failing."));
      }
    }, waiting: 'Waiting for clean to complete...');
  }

  /// compiles all dart scripts in the project.
  void compile({bool install, bool overright}) {
    find('*.dart', root: pathToProjectRoot).forEach((file) =>
        Script.fromFile(file).compile(install: install, overwrite: overright));
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
      name: '.script.lock',
      lockPath: pathToProjectRoot,
    ).withLock(() {
      var pubGet = PubGet(this);
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

  /// We have:
  /// * pubspec.yaml
  /// * pubspec.lock
  /// *
  bool get isReadyToRun {
    // TODO: this is still risky as pub get does a test to see if the versions have changed.
    // we could improve this by checking that the .lock files date is after the .yamls date.
    /// there is a 'generated' date stamp in the .json file which might be more definitive.
    return (exists(
            join(pathToProjectRoot, '.dart_code', 'package_config.json')) &&
        exists(join(pathToProjectRoot, 'pubspec.lock')) &&
        (hasPubSpec));
  }

  bool get hasPubSpec => exists(join(pathToProjectRoot, 'pubspec.yaml'));
  bool get hasAnalysisOptions =>
      exists(join(pathToProjectRoot, 'analysis_options.yaml'));

  void prepareToRun() {
    if (!hasPubSpec) {
      _createPubspecFromTemplate(showWarnings: false);
    }

    if (!hasAnalysisOptions) {
      /// add pedantic to the project
      _createAnalysisOptionsFromTemplate(showWarnings: false);
    }
  }

  /// Creates a script located at [scriptPath] from the passed [templatePath].
  /// When the user runs 'dcli create <script>'
  void createFromTemplate({String templatePath, String pathToScript}) {
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

    var analysisPath =
        join(dirname(pathToProjectRoot), 'analysis_options.yaml');
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
    replace(pathToPubSpec, '%scriptname%', basename(pathToProjectRoot));
  }

  Script createScript(String pathToScript) {
    createFromTemplate(
      templatePath: join(Settings().pathToTemplate, 'cli_args.dart'),
      pathToScript: pathToScript,
    );

    return Script.fromFile(pathToScript, project: this);
  }
}
