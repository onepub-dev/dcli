/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

part of dart_project;

/// Used for unit testing.
/// When this environment variable exists the [DartProject.create] method
/// will add a `pubspec_overrides.yaml` file in the created project
/// with overrides for dcli and dcli_core which point
/// to our dev source tree.
@visibleForTesting
const String overrideDCliPathKey = 'DCLI_OVERRIDE_PATH';

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

  _fixPubspec(projectName, project.pubSpec, project.pathToPubSpec);

  /// rename main.dart from the template to <projectname>.dart
  // ignore: discarded_futures
  final projectScript = _renameMain(project, projectName);

  if (!Settings().isWindows) {
    chmod(projectScript, permission: '755');
  }

  if (env.exists(overrideDCliPathKey)) {
    /// we are running in a unit test so
    /// we need to add pubspec overrides so that the
    /// newly created project will from the dev source
    /// for dcli and dcli_core rather than looking to pub.dev.
    addUnitTestOverrides(pathToProject);
  }

  find('*.*', workingDirectory: pathToProject, includeHidden: true)
      .forEach((file) {
    print('    $file');
  });

  print('');
  DartSdk()
      .runPubGet(project.pathToProjectRoot, progress: Progress.printStdErr());

  _printCreated(projectName, project);
}

void addUnitTestOverrides(String pathToProject) {
  /// we are running in a unit test so
  /// we need to add pubspec overrides so that the
  /// newly created project will from the dev source
  /// for dcli and dcli_core rather than looking to pub.dev.
  final pathToDCliRoot = _pathToDCliGitRoot();

  join(pathToProject, 'pubspec_overrides.yaml').write('''
dependency_overrides: 
  dcli: 
    path: ${join(pathToDCliRoot, 'dcli')}
  dcli_common: 
    path: ${join(pathToDCliRoot, 'dcli_common')}
  dcli_core: 
    path: ${join(pathToDCliRoot, 'dcli_core')}
  dcli_input: 
    path: ${join(pathToDCliRoot, 'dcli_input')}
  dcli_terminal: 
    path: ${join(pathToDCliRoot, 'dcli_terminal')}  
''');
}

String _pathToDCliGitRoot() {
  var dcliGitRoot = DartProject.self.pathToProjectRoot;
  // If [dcliGitRoot] contains a pubspec.yaml then it
  // isn't the project root.

  while (DartProject.findProject(dcliGitRoot) != null) {
    // search up the tree until we find a directory that
    // doesn't have a pubspec.yaml in a parent dire.
    dcliGitRoot = dirname(dcliGitRoot);
  }

  return dcliGitRoot;
}

/// update the templates dcli version to match the dcli version
/// the user is running.
void _fixPubspec(String projectName, PubSpec pubSpec, String pathToPubSpec) {
  final current = pubSpec.dependencies;

  if (current.exists('dcli')) {
    final dcli = current['dcli'];

    if (dcli is DependencyVersioned) {
      (dcli! as DependencyVersioned).versionConstraint = packageVersion;
    }
  }

  if (current.exists('dcli_core')) {
    final dcliCore = current['dcli_core'];

    if (dcliCore is DependencyVersioned) {
      (dcliCore! as DependencyVersioned).versionConstraint = packageVersion;
    }
  }

  pubSpec
    ..name.set(_replaceInvalidCharactersForName(projectName))
    ..saveTo(pathToPubSpec);
}

/// Returns the name of the main project script.
String _renameMain(DartProject project, String projectName) {
  /// rename main.dart from the template to <projectname>.dart
  final mainScript = join(project.pathToBinDir, 'main.dart');
  final projectScript = join(project.pathToBinDir, '$projectName.dart');

  if (exists(projectScript)) {
    return projectScript;
  }

  String? orginalScriptName;

  if (exists(mainScript)) {
    orginalScriptName = mainScript;
    move(mainScript, projectScript);
  } else {
    /// no main.dart so find the first script in bin and rename it
    final scripts =
        find('*.dart', workingDirectory: project.pathToBinDir).toList();
    if (scripts.isNotEmpty) {
      move(scripts.first, projectScript);
      orginalScriptName = scripts.first;
    }
  }

  /// If the pubspec includes an executables clause that
  /// reference the script we just changed the name of,
  /// then update the pubpsec to reflect the new name.
  final pubspec = PubSpec.loadFromPath(project.pathToPubSpec);
  if (orginalScriptName != null) {
    final executables = pubspec.executables;
    final originalScriptKey = basenameWithoutExtension(orginalScriptName);

    if (executables.exists(originalScriptKey)) {
      final execName = basenameWithoutExtension(projectScript);
      executables[originalScriptKey]!.name = execName;

      pubspec.save();
    }
  }

  return projectScript;
}

void _createFromTemplate(String pathToTemplate, String pathToProject,
    String projectName, String templateName) {
  copyTree(pathToTemplate, pathToProject, includeHidden: true);

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
    throw InvalidArgumentException(
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
      //replace(file, templateName, projectName, all: true);

      if (extension(file) == '.dart') {
        replace(file, 'package:$templateName/', 'package:$projectName/');
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
    throw DartProjectException('The template $templateName does not exist in '
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

class InvalidProjectTemplateException extends DCliException {
  InvalidProjectTemplateException(super.message);
}
