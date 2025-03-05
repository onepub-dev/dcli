import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

import 'dcli/resource/generated/resource_registry.g.dart';


/// Checks if the template directory exists in ~/.dcli and if not creates
/// the directory and copies the default scripts in.
void initTemplates(void Function(String) progress) {
  initProjectTemplates(progress);
  initScriptTemplates(progress);

  for (final resource in ResourceRegistry.resources.values) {
    if (resource.originalPath.startsWith('template')) {
      resource.unpack(join(Settings().pathToDCli, resource.originalPath));
    }
  }
}

void initProjectTemplates(void Function(String) progress) {
  if (!exists(Settings().pathToTemplateProjectCustom)) {
    createDir(Settings().pathToTemplateProjectCustom, recursive: true);
  }

  /// delete all non-custom project templates
  find('*',
          types: [Find.directory],
          recursive: false,
          workingDirectory: Settings().pathToTemplateProject)
      .forEach((dir) {
    // dont' delete anything under custom.
    if (!dir.startsWith(Settings().pathToTemplateProjectCustom)) {
      if (exists(dir)) {
        deleteDir(dir);
      }
    }
  });

  /// create the template directory.
  if (!exists(Settings().pathToTemplateProject)) {
    progress(
      '${blue('Creating')} ${green('project templates')} '
      '${blue('directory: ${Settings().pathToTemplateProject}.')}',
    );
  } else {
    progress(
      '${blue('Updating ${green('project templates')} ')}'
      '${blue('directory: ${Settings().pathToTemplateProject}.')}',
    );
  }

  if (!exists(Settings().pathToTemplateProject)) {
    createDir(Settings().pathToTemplateProject, recursive: true);
  }

  if (!exists(Settings().pathToTemplateProjectCustom)) {
    createDir(Settings().pathToTemplateProjectCustom, recursive: true);
  }
}

void initScriptTemplates(void Function(String) progress) {
  if (!exists(Settings().pathToTemplateScriptCustom)) {
    createDir(Settings().pathToTemplateScriptCustom, recursive: true);
  }

  /// delete all non-custom script templates
  find('*',
          types: [Find.directory],
          recursive: false,
          workingDirectory: Settings().pathToTemplateScript)
      .forEach((dir) {
    // dont' delete anything under custom.
    if (!dir.startsWith(Settings().pathToTemplateScriptCustom)) {
      deleteDir(dir);
    }
  });

  /// create the template directory.
  if (!exists(Settings().pathToTemplateProject)) {
    progress(
      '${blue('Creating')} ${green('script templates')} '
      '${blue('directory: ${Settings().pathToTemplateScript}.')}',
    );
  } else {
    progress(
      '${blue('Updating ${green('script template')} ')}'
      '${blue('directory: ${Settings().pathToTemplateScript}.')}',
    );
  }

  if (!exists(Settings().pathToTemplateScript)) {
    createDir(Settings().pathToTemplateScript, recursive: true);
  }

  if (!exists(Settings().pathToTemplateScriptCustom)) {
    createDir(Settings().pathToTemplateScriptCustom, recursive: true);
  }
}
