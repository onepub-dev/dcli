/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:path/path.dart';

import '../../dcli.dart';
import '../script/command_line_runner.dart';
import '../script/flags.dart';
import '../util/resources.dart';
import 'commands.dart';

/// Implementation for the 'pack' command.
/// The 'pack' command will scan the 'resource' directory under
/// your project root and  all subdirectories.
/// Each file that it finds is base64 encoded
/// and placed into dart library under:
///
/// ```
/// <project root>/lib/src/dcli/resource
/// ```
///
/// So the following resources:
/// ```text
/// <project root>/resource/
///             images/photo.png
///             data/zips/installer.zip
/// ```
///
/// Will be converted to:
///
/// ```text
/// <project root>/lib/src/resource/
///             images/photo_png.dart
///             data/zips/installer_zip.dart
/// ```
///
/// You can also add in file external to your project by creating
/// <your project>/tool/dcli/pack.yaml
/// The pack.yaml declares a number of external directories to be packed
/// and how they are to be mounted under the resource directory.
///
/// ```yaml
/// externals:
///   - external:
///     path: ../template/basic
///     mount: template/basic
///   - external:
///     path: ../template/cmd_args
///     mount: template/cmd_args
/// ```
///
/// As part of the packing process DCli also creates a registry of the
/// resources packed.
/// This is done by creating a dart library called 'lib/src/dcli/resource/generated/resource_registry.g.dart'.
/// The contents of the 'resource/generated/resource_registry.g.dart' are of the form.
///
/// ```text
///
/// static const Map<String, PackedResource> resources = {
/// 'images/photo.png': PackedResource('images/photo.png', <library_name>),
/// 'data/zips/installer.zip': PackedResource('data/zips/installer.zip', '<library_name>)
/// };
///
/// Each of the resouces will be placed in a generated dart library of the form
/// lib/src/dcli/resource/generated/<uuid>.g.dart
///
/// ```

class PackCommand extends Command {
  ///
  PackCommand() : super(_commandName);

  static const String _commandName = 'pack';

  /// [arguments] contains path to clean
  @override
  Future<int> run(List<Flag> selectedFlags, List<String> arguments) async {
    if (!exists(Resources().resourceRoot) &&
        !exists(Resources.pathToPackYaml)) {
      throw InvalidCommandArgumentException(
          'Unable to pack resources as neither a resource directory at '
          '${Resources().resourceRoot}'
          ' nor ${Resources.pathToPackYaml} exists.');
    }

    if (!exists(Resources().resourceRoot)) {
      print(orange('${Resources().resourceRoot} not found. '
          'Only external resources will be packed'));
    }

    try {
      Resources().pack();
    } on ResourceException catch (e) {
      printerr(red(e.message));
      return 1;
    }
    return 0;
  }

  @override
  String usage() => '''pack''';

  @override
  String description({bool extended = false}) {
    var desc = '''
Pack all files under the '${relative(Resources().resourceRoot)}' directory or 
   those listed in pack.yaml which can be unpacked at install time.''';
    if (extended) {
      desc += '''
      
To include resources located outside of you package directory create tool/pack.yaml.
https://dcli.noojee.dev/dcli-api/assets#external-resources
''';
    }
    return desc;
  }

  @override
  List<String> completion(String word) => [word];

  @override
  List<Flag> flags() => [];
}
