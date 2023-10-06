/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:path/path.dart';

import '../../dcli.dart';
import '../../posix.dart';

/// Creates a script in [project] with the name [scriptName]
/// using the template [templateName] which defaults to (simple.dart)
///
/// The [scriptName] MUST end in .dart otherwise a [DartProjectException]
/// is thrown
///
/// The [templateName] must be the name of a template file in the ~/.dcli/template/script directory.
///
DartScript scriptCreator(
    {required DartProject project,
    required String scriptName,
    required String templateName}) {
  final pathToProjectRoot = project.pathToProjectRoot;

  final pathToScript = join(pwd, scriptName);
  verbose(() => 'pathToScript $pathToScript');

  if (exists(pathToScript)) {
    throw ScriptExistsException('The script $pathToScript already exists');
  }
  final pathToTemplate = _resolveTemplatePath(templateName);
  verbose(() => 'pathToTemplate $pathToTemplate');

  _printCreating(scriptName, pathToTemplate, pathToProjectRoot);

  if (!scriptName.endsWith('.dart')) {
    throw DartProjectException('scriptName must end with .dart');
  }

  _createFromTemplate(pathToTemplate, pathToScript, templateName,
      pathToProjectRoot, scriptName);

  _applyTransforms(
      pathToScript: pathToScript,
      scriptName: scriptName,
      templateName: templateName);

  DartSdk().runPubGet(pathToProjectRoot, progress: Progress.printStdErr());

  /// mark the script as exectuable
  if (!Settings().isWindows) {
    chmod(pathToScript, permission: '755');
  }

  _printCreated(scriptName, project);

  return DartScript.fromFile(pathToScript, project: project);
}

void _createFromTemplate(String pathToTemplate, String pathToScript,
    String templateName, String pathToProjectRoot, String scriptName) {
  final mainScript = join(pathToTemplate, 'main.dart');
  if (exists(mainScript)) {
    copy(mainScript, pathToScript);
  } else {
    /// we copy the first script we find in the script template dir
    final scripts = find('*.dart', workingDirectory: pathToTemplate).toList();

    if (scripts.isEmpty) {
      throw InvalidTemplateException(
          'The template $templateName does not contain a dart script.');
    }
    copy(scripts.first, join(pathToProjectRoot, scriptName));
  }
}

void _printCreated(String scriptName, DartProject project) {
  final runPath = scriptName.contains(Platform.pathSeparator)
      ? scriptName
      : join('.', scriptName);
  print('''
  
  Created script $scriptName in ${truepath(project.pathToProjectRoot)}.
  
  To run your script:
  
    $runPath
  
  ''');
}

void _printCreating(
    String scriptName, String pathToTemplate, String pathToProjectRoot) {
  print('');
  print('Creating $scriptName from $pathToTemplate.');
  print('');
  verbose(() => 'createScript $scriptName: $scriptName '
      'projectRoot: $pathToProjectRoot');
}

String _resolveTemplatePath(String templateName) {
  String? pathToTemplate;
  var found = false;
  // First check if a custom template exists.
  if (exists(join(Settings().pathToTemplateScriptCustom, templateName))) {
    pathToTemplate = join(Settings().pathToTemplateScriptCustom, templateName);
    found = true;
  }

  // check that the value contains the name of a valid template
  if (exists(join(Settings().pathToTemplateScript, templateName))) {
    pathToTemplate = join(Settings().pathToTemplateScript, templateName);
    found = true;
  }
  if (!found) {
    throw DartProjectException("The template '$templateName' does not exist in "
        '${Settings().pathToTemplateScript}'
        ' or ${Settings().pathToTemplateScriptCustom}.');
  }
  return pathToTemplate!;
}

void _applyTransforms(
    {required String pathToScript,
    required String scriptName,
    required String templateName}) {
  /// Apply some crude transformations to the templates
  /// ignore: flutter_style_todos
  /// TODO(bsutton): we need to allow a template to define a set of transforms
  /// such as file renames and string substitutions.
  replace(pathToScript, templateName, scriptName, all: true);
}

class ScriptExistsException extends DartProjectException {
  ScriptExistsException(super.message);
}
