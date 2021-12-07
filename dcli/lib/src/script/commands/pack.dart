import 'package:path/path.dart';

import '../../functions/is.dart';
import '../../util/resources.dart';
import '../command_line_runner.dart';
import '../flags.dart';
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
  int run(List<Flag> selectedFlags, List<String> arguments) {
    if (!exists(Resources().resourceRoot)) {
      throw InvalidArguments(
          'An able to pack resources as the resource directory at '
          '${Resources().resourceRoot}'
          " doesn't exist.");
    }
    Resources().pack();
    return 0;
  }

  @override
  String usage() => 'pack';

  @override
  String description() => '''
Pack all files under the '${relative(Resources().resourceRoot)}' directory into a set of dart
   libraries which can be unpacked at install time.''';

  @override
  List<String> completion(String word) => [word];

  @override
  List<Flag> flags() => [];
}
