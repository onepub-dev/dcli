import 'dart:io';

import 'package:path/path.dart';

import '../../dcli.dart';
import '../functions/find.dart';
import '../pubspec/pubspec.dart';
import '../settings.dart';
import 'pub_get.dart';

/// Encapsulates the idea of a dart project which is made up
/// of a pubspec.yaml, dart files ....

class DartProject {
  /// Load a dart project from the given directory.
  /// We search up the tree starting from [pathToSearchFrom]
  /// until we find a pubspec.yaml and that becomes the
  /// project root. directory.
  /// Set [search] to false if you don't want to search up the
  /// directory tree for a pubspec.yaml.
  DartProject.fromPath(String pathToSearchFrom, {bool search = true}) {
    if (search) {
      _pathToProjectRoot = _findProjectRoot(pathToSearchFrom);
    } else {
      _pathToProjectRoot = pathToSearchFrom;
    }
    _pathToProjectRoot = truepath(_pathToProjectRoot);
    verbose(() => 'DartProject.fromPath: $_pathToProjectRoot');
  }

  /// Loads the project from the dart pub cache
  /// named [name] for the version [version].
  /// e.g. ~/.pub-cache/hosted/pub.dartlang.org/dswitch-4.0.1
  DartProject.fromCache(String name, String version) {
    _pathToProjectRoot = truepath(PubCache().pathToPackage(name, version));
  }
  late String _pathToProjectRoot;
  String? _pathToPubSpec;

  static DartProject? _current;

  /// If you
  @Deprecated('Use DartProject.self')
  static DartProject get current => self;

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
    if (Platform.packageConfig != null) {
      /// When running as a unit test we can't use DartScript.current
      /// as it returns the the test runner.
      /// The packageConfig is available if passed (which unit tests do)
      /// and when passed is probably the most relable means of
      /// determining the project directory.
      return _current ??=
          DartProject.fromPath(dirname(Platform.packageConfig!));
    }
    final script = DartScript.self;
    var startFrom = '.';
    if (!script.isCompiled) {
      startFrom = script.pathToScript;
    }
    return _current ??= DartProject.fromPath(startFrom);
  }

  ///
  /// reads and returns the project's virtual pubspec
  /// and returns it.
  PubSpec get pubSpec => PubSpec.fromFile(pathToPubSpec);

  /// Absolute path to the project's root diretory.
  String get pathToProjectRoot => _pathToProjectRoot;

  /// Absolute path to the project's 'tool' directory.
  String get pathToToolDir => truepath(_pathToProjectRoot, 'tool');

  /// Absolute path to the project's 'bin' directory.
  String get pathToBinDir => truepath(_pathToProjectRoot, 'bin');

  /// Absolute path to the project's 'test' directory.
  String get pathToTestDir => truepath(_pathToProjectRoot, 'test');

  /// Absolute path to the project's '.dart_tool' directory.
  String get pathToDartToolDir => truepath(_pathToProjectRoot, '.dart_tool');

  /// Absolute pathto the project's pubspec.yaml
  String get pathToPubSpec =>
      _pathToPubSpec ??= join(_pathToProjectRoot, 'pubspec.yaml');

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
    for (final name in pubSpec.dependencies.keys) {
      _colprint(name, pubSpec.dependencies[name]!.rehydrate());
    }
  }

  void _colprint(String label, String value, {int pad = 25}) {
    print('${label.padRight(pad)}: $value');
  }

  String _makeSafe(String line) => line.replaceAll(HOME, '<HOME>');

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

  NamedLock? __lock;
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
          '${DCliPaths().dcliName} '
                  '-v=${join(Directory.systemTemp.path, 'dcli.warmup.log')}'
                  ' warmup $pathToProjectRoot'
              .start(detached: true, runInShell: true, extensionSearch: false);
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
        workingDirectory: pathToProjectRoot,
      ).forEach(delete);
      find(
        '.dart_tool',
        types: [Find.directory],
        workingDirectory: pathToProjectRoot,
      ).forEach(deleteDir);
      find('pubspec.lock', workingDirectory: pathToProjectRoot).forEach(delete);

      find('*.dart', workingDirectory: pathToProjectRoot).forEach((scriptPath) {
        final script = DartScript.fromFile(scriptPath);
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
    find('*.dart', workingDirectory: pathToProjectRoot).forEach((file) =>
        DartScript.fromFile(file)
            .compile(install: install, overwrite: overwrite));
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

        // ignore: flutter_style_todos
        /// TODO(bsutton): should this be a throw?
        exit(1);
      }
      pubGet.run(compileExecutables: false);
    });
  }

  // TODO(bsutton): this is still risky as pub get does a test to see if
  // the versions have changed.
  // we could improve this by checking that the .lock files date
  //  is after the .yamls date.
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
      exists(join(pathToProjectRoot, '.dart_tool', 'package_config.json')) &&
      exists(join(pathToProjectRoot, 'pubspec.lock')) &&
      hasPubSpec;

  /// Returns true if the project contains a pubspec.yaml.
  bool get hasPubSpec => exists(join(pathToProjectRoot, 'pubspec.yaml'));

  /// Returs true if the project has an 'analyssi_options.yaml' file.
  bool get hasAnalysisOptions =>
      exists(join(pathToProjectRoot, 'analysis_options.yaml'));

  /// Prepares the project by creating a pubspec.yaml and
  /// the analysis_options.yaml file.
  void initFiles() {
    if (!hasPubSpec) {
      _createPubspecFromTemplate();
    }

    if (!hasAnalysisOptions) {
      /// add pedantic to the project
      _createAnalysisOptionsFromTemplate();
    }
  }

  /// Creates a script located at [pathToScript] from the passed [templatePath].
  /// When the user runs 'dcli create <script>'
  void _createFromTemplate(
      {required String templatePath, required String pathToScript}) {
    if (!exists(templatePath)) {
      throw TemplateNotFoundException(templatePath);
    }
    copy(templatePath, pathToScript);

    replace(pathToScript, '%dcliName%', DCliPaths().dcliName);
    replace(pathToScript, '%scriptname%', basename(pathToScript));

    if (!hasPubSpec) {
      _createPubspecFromTemplate();
    }
    if (!hasAnalysisOptions) {
      _createAnalysisOptionsFromTemplate();
    }
  }

  void _createAnalysisOptionsFromTemplate({bool showWarnings = false}) {
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

  void _createPubspecFromTemplate({bool showWarnings = false}) {
    if (showWarnings) {
      print(orange('Creating missing pubspec.yaml.'));
    }
    // no pubspec.yaml in scope so lets create one.

    copy(join(Settings().pathToTemplate, 'pubspec.yaml.template'),
        pathToPubSpec);
    replace(pathToPubSpec, '%scriptname%',
        _replaceInvalidCharactersForName(basename(pathToProjectRoot)));
  }

  /// Creates a script in [pathToProjectRoot] with the name [scriptName]
  /// using the based [templateName] which defaults to (basic.dart)
  ///
  /// The [scriptName] MUST end in .dart otherwise a [DartProjectException]
  /// is thrown
  ///
  /// The [templateName] must be the name of a template file in the ~/.dcli/template directory.
  ///
  DartScript createScript(String scriptName,
      {String templateName = 'basic.dart'}) {
    if (!scriptName.endsWith('.dart')) {
      throw DartProjectException('scriptName must end with .dart');
    }
    final pathToScript = join(pathToProjectRoot, scriptName);
    _createFromTemplate(
      templatePath: join(Settings().pathToTemplate, templateName),
      pathToScript: pathToScript,
    );

    return DartScript.fromFile(pathToScript, project: this);
  }

  /// The name used in the pubspec.yaml must come from the character
  ///  set [a-z0-9_]
  /// so wer replace any invalid character with an '_'.
  String _replaceInvalidCharactersForName(String proposedName) =>
      proposedName.replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');
}

/// Exception for issues with DartProjects.
class DartProjectException extends DCliException {
  /// Create a DartProject related exceptions
  DartProjectException(String message) : super(message);
}

/// The requested DCli template does not exists.
class TemplateNotFoundException extends DCliException {
  /// The requested DCli template does not exists.
  TemplateNotFoundException(String pathTo)
      : super('The template $pathTo does not exist.');
}
