part of dart_project;

void _createProject(String pathToProject, String templateName) {
  verbose(() => '_createProject $pathToProject from $templateName');

  final pathToTemplate = _resolveTemplatePath(templateName);
  verbose(() => 'pathToTemplate $pathToTemplate');

  final projectName = basename(pathToProject);

  _validateProjectName(projectName);

  _printCreating(projectName, pathToTemplate);

  createDir(pathToProject, recursive: true);

  _createFromTemplate(pathToTemplate, pathToProject, projectName, templateName);

  final project = DartProject.fromPath(pathToProject, search: false);

  if (!project.hasPubSpec) {
    throw InvalidProjectTemplateException(
        'The template ${dirname(pathToTemplate)} '
        'at $pathToTemplate '
        'is not valid as it does not contain a pubspec.yaml');
  }

  project.pubSpec
    ..name = _replaceInvalidCharactersForName(projectName)
    ..saveToFile(project.pathToPubSpec);

  /// rename main.dart from the template to <projectname>.dart
  final projectScript = _renameMain(project, projectName);

  if (!Settings().isWindows) {
    chmod(projectScript, permission: '755');
  }

  print('');
  DartSdk()
      .runPubGet(project.pathToProjectRoot, progress: Progress.printStdErr());

  _printCreated(projectName, project);
}

String _renameMain(DartProject project, String projectName) {
  /// rename main.dart from the template to <projectname>.dart
  final mainScript = join(project.pathToBinDir, 'main.dart');
  final projectScript = join(project.pathToBinDir, '$projectName.dart');
  if (exists(mainScript)) {
    move(mainScript, projectScript);
  } else {
    /// no main.dart so find the first script in bin and rename it
    final scripts =
        find('*.dart', workingDirectory: project.pathToBinDir).toList();
    if (scripts.isNotEmpty) {
      move(scripts.first, projectScript);
    }
  }
  return projectScript;
}

void _createFromTemplate(String pathToTemplate, String pathToProject,
    String projectName, String templateName) {
  final prefix = '$pathToTemplate${Platform.pathSeparator}';
  copyTree(pathToTemplate, pathToProject, includeHidden: true, filter: (file) {
    print('    ${file.replaceAll(prefix, '')}');
    return true;
  });

  _applyTransforms(
      projectName: projectName,
      pathToProject: pathToProject,
      templateName: templateName);
}

void _printCreated(String projectName, DartProject project) {
  print('');
  print('Created project $projectName in '
      '${truepath(project.pathToProjectRoot)}.');
  print('');
  print('To get started:');
  print('');
  print('  cd $projectName');
  print('  bin/$projectName.dart');
  print('');
}

void _printCreating(String projectName, String pathToTemplate) {
  print('Creating $projectName from template $pathToTemplate.');
  print('');
}

/// Returns `true` if [projectName] is valid Dart variable identifier.
void _validateProjectName(String projectName) {
  // Contains only valid characters and starts with a non-numeric character.
  final regExp = RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*');
  final match = regExp.stringMatch(projectName);
  if (match != projectName) {
    throw InvalidArgumentsException(
        'The project name $projectName is not a valid dart indentifier.');
  }
}

void _applyTransforms(
    {required String projectName,
    required String pathToProject,
    required String templateName}) {
  /// Apply some crude transformations to the templates
  /// ignore: flutter_style_todos
  /// TODO(bsutton): we need to allow a template to define a set of transforms
  /// such as file renames and string substitutions.
  find('*', workingDirectory: pathToProject).forEach((file) {
    if (templateName != projectName) {
      replace(file, templateName, projectName, all: true);
      if (basenameWithoutExtension(file) == templateName) {
        move(file, join(dirname(file), '$projectName.dart'));
      }
    }
  });
}

String _resolveTemplatePath(String templateName) {
  String? pathToTemplate;
  var found = false;
  // First check if a custom template exists.
  if (exists(join(Settings().pathToTemplateProjectCustom, templateName))) {
    pathToTemplate = join(Settings().pathToTemplateProjectCustom, templateName);
    found = true;
  }

  // check that the value contains the name of a valid template
  if (exists(join(Settings().pathToTemplateProject, templateName))) {
    pathToTemplate = join(Settings().pathToTemplateProject, templateName);
    found = true;
  }
  if (!found) {
    throw InvalidFlagOptionException(
        'The template $templateName does not exist in '
        '${Settings().pathToTemplateProject}'
        ' or ${Settings().pathToTemplateProjectCustom}.');
  }
  return pathToTemplate!;
}

// void _createAnalysisOptionsFromTemplate(
//     {required String pathToProjectRoot,
//     required String pathToPubSpec,
//     bool showWarnings = false}) {
//   /// add pedantic to the project

//   final analysisPath = join(pathToProjectRoot, 'analysis_options.yaml');
//   if (!exists(analysisPath)) {
//     if (showWarnings) {
//       print(orange('Creating missing analysis_options.yaml.'));
//     }

//     copy(
//       join(Settings().pathToTemplate, 'analysis_options.yaml.template'),
//       analysisPath,
//     );
//   }
// }

// void _createPubspecFromTemplate(
//     {required String pathToProjectRoot,
//     required String pathToPubSpec,
//     bool showWarnings = false}) {
//   if (showWarnings) {
//     print(orange('Creating missing pubspec.yaml.'));
//   }
//   // no pubspec.yaml in scope so lets create one.

//   copy(
//     join(Settings().pathToTemplate, 'pubspec.yaml.template'),
//     pathToPubSpec,
//   );
//   replace(
//       pathToPubSpec,
//       'name: scriptname',
//       'name: '
//           '${_replaceInvalidCharactersForName(
// basename(pathToProjectRoot))}');
// }

/// The name used in the pubspec.yaml must come from the character
///  set [a-z0-9_]
/// so wer replace any invalid character with an '_'.
String _replaceInvalidCharactersForName(String proposedName) {
  var fixed = proposedName.replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');

  /// must start with an alpha.
  if (RegExp('[a-zA-Z]').matchAsPrefix(fixed) == null) {
    fixed = 'a$fixed';
  }
  return fixed;
}

/// Allows a user to select which template to use when
/// creating a project.
class TemplateFlag extends Flag {
  ///
  factory TemplateFlag() => _self;

  ///
  TemplateFlag._internal() : super(flagName);

  static const defaultTemplateName = 'simple';
  static const flagName = 'template';
  static final _self = TemplateFlag._internal();

  static late final String defaultTemplatePath =
      join(Settings().pathToTemplateProject, defaultTemplateName);

  String? _templateName;

  @override
  // Returns the templateName
  String get option => _templateName!;

  /// true if the flag has an option.
  bool get hasOption => _templateName != null;

  @override
  bool get isOptionSupported => true;

  @override
  set option(String? _value) {
    _templateName = _value ?? defaultTemplateName;
  }

  @override
  String get abbreviation => 't';

  @override
  String usage() =>
      '--$flagName=<template name> | -$abbreviation=<template name>';

  @override
  String description() => '''
      Defines the name of the template to create the script or project from.
      If not passed the 'simple' template is used.''';
}

class InvalidProjectTemplateException extends DCliException {
  InvalidProjectTemplateException(String message) : super(message);
}

/// Prints a list of the templates and exists
class TemplateListFlag extends Flag {
  ///
  factory TemplateListFlag() => _self;

  ///
  TemplateListFlag._internal() : super(flagName);

  static const flagName = 'list';
  static final _self = TemplateListFlag._internal();

  @override
  String get option => '';

  /// true if the flag has an option.
  bool get hasOption => false;

  @override
  bool get isOptionSupported => false;

  @override
  set option(String? _value) {}

  @override
  String get abbreviation => 'l';

  @override
  String usage() => '--$flagName';

  @override
  String description() => '''
      Prints a list of project and script templates then exits.
''';
}