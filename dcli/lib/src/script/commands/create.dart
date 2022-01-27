import '../../../dcli.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

/// implementation of the 'create' command
class CreateCommand extends Command {
  ///
  CreateCommand() : super(_commandName);
  static const String _commandName = 'create';

  final _createFlags = [
    TemplateFlag(),
    TemplateListFlag()
  ]; // ForegroundFlag(),

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var scriptIndex = 0;
    TemplateFlag? templateFlag;

    if (Shell.current.isSudo) {
      printerr('You cannot create a script or a project as sudo.');
      return 1;
    }

    // check for any flags
    for (var i = 0; i < subarguments.length; i++) {
      final subargument = subarguments[i];

      if (Flags.isFlag(subargument)) {
        final flag = flagSet.findFlag(subargument, _createFlags);

        if (flag != null) {
          if (flagSet.isSet(flag)) {
            throw DuplicateOptionsException(subargument);
          }
          flagSet.set(flag);
          verbose(() => 'Setting flag: ${flag.name}');
          if (flag is TemplateFlag) {
            templateFlag = flag;
          }
          continue;
        } else {
          throw UnknownFlag(subargument);
        }
      }
      scriptIndex = i;

      break;
    }

    if (flagSet.isSet(TemplateListFlag())) {
      _printTemplates();
      return 0;
    }

    final target = _retrieveTarget(subarguments.sublist(scriptIndex));
    final templateName = templateFlag != null
        ? templateFlag.option
        : TemplateFlag.defaultTemplateName;

    try {
      if (target.endsWith('.dart')) {
        /// create a script
        final project = DartProject.findProject(dirname(target));

        if (project == null) {
          printerr(red('The current directory is not a Dart Project. '
              'Use dcli create <projectname> to create a project.'));
          return 1;
        }

        DartScript.createScript(
            project: project, scriptName: target, templateName: templateName);
      } else {
        /// create a project
        DartProject.create(pathTo: target, templateName: templateName);
      }
    } on TemplateNotFoundException catch (e) {
      printerr(red(e.message));
      print('Install DCli and try again.');
      print(blue(Shell.current.installInstructions));
      return 1;
    }

    return 0;
  }

  /// Extracts the target from the args. This will either be a
  /// dart file or a diretory if the user wants to create an
  /// entire project.
  /// <script.dart> | <project path>
  String _retrieveTarget(List<String> arguments) {
    if (arguments.length != 1) {
      throw InvalidArgumentsException(
        'The create command takes one argument. '
        'Found: ${arguments.join(',')}',
      );
    }
    final target = arguments[0];
    if (extension(target) == '.dart') {
      /// create a single dart script within an existing project
      if (exists(target)) {
        throw InvalidArgumentsException(
          'The script ${truepath(target)} already exists.',
        );
      }

      /// check the script directory exists
      if (!exists(dirname(target))) {
        throw InvalidArgumentsException('The script directory '
            '${truepath(dirname(target))} must already exists.');
      }
    } else {
      /// Create a new dart project
      /// check the project directory doesn't exists
      if (exists(target)) {
        throw InvalidArgumentsException('The project directory '
            '${truepath(target)} already exists.');
      }
    }

    return target;
  }

  @override
  String description({bool extended = false}) =>
      'Creates a script or project from a template.';

  @override
  String usage() => 'create --list | '
      'create [--template=<template name>] '
      '<script path.dart | project path>';

  @override
  List<String> completion(String word) => <String>[];

  @override
  List<Flag> flags() => _createFlags;

  /// print a list of project and script templates
  void _printTemplates() {
    print('');
    print(green('Project templates'));
    find('*',
            types: [Find.directory],
            workingDirectory: Settings().pathToTemplateProject,
            recursive: false)
        .forEach((templateDir) {
      if (templateDir != Settings().pathToTemplateProjectCustom) {
        print('  ${basename(templateDir)}');
      }
    });

    print('');
    print(green('Custom Project templates'));
    find('*',
            types: [Find.directory],
            workingDirectory: Settings().pathToTemplateProjectCustom,
            recursive: false)
        .forEach((templateDir) {
      print('  ${basename(templateDir)}');
    });

    print('');
    print(green('Script templates'));
    find('*',
            types: [Find.directory],
            workingDirectory: Settings().pathToTemplateScript,
            recursive: false)
        .forEach((templateDir) {
      if (templateDir != Settings().pathToTemplateScriptCustom) {
        print('  ${basename(templateDir)}');
      }
    });
    print('');
    print(green('Custom Script templates'));
    find('*',
            types: [Find.directory],
            workingDirectory: Settings().pathToTemplateScriptCustom,
            recursive: false)
        .forEach((templateDir) {
      print('  ${basename(templateDir)}');
    });
    print('');
  }
}

///
class ForegroundFlag extends Flag {
  ///
  ForegroundFlag() : super(_flagName);

  static const _flagName = 'foreground';

  @override
  String get abbreviation => 'fg';

  @override
  String description() =>
      '''Stops the create from running pub get in the background.''';
}
