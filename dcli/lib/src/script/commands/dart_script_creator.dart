import '../../../dcli.dart';
import '../../../posix.dart';
import '../flags.dart';

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

  final pathToTemplate = _resolveTemplatePath(templateName);

  print('Creating $scriptName from $pathToTemplate');
  verbose(() => 'createScript $scriptName: $scriptName '
      'projectRoot: $pathToProjectRoot');
  if (!scriptName.endsWith('.dart')) {
    throw DartProjectException('scriptName must end with .dart');
  }
  final pathToScript = join(pathToProjectRoot, basename(scriptName));
  verbose(() => 'pathToScript $pathToScript');

  copy(pathToTemplate, join(pathToProjectRoot, scriptName));

  /// mark the script as exectuable
  if (!Settings().isWindows) {
    chmod(pathToScript, permission: '755');
  }

  //project.warmup(background: !flagSet.isSet(ForegroundFlag()));

  print('');

  print('To run your script:\n   ./$scriptName');

  return DartScript.fromFile(pathToScript, project: project);
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
    throw InvalidFlagOption('The template $templateName does not exist in '
        '${Settings().pathToTemplateProject}'
        ' or ${Settings().pathToTemplateProjectCustom}.');
  }
  return pathToTemplate!;
}
