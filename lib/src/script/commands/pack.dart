import '../../util/resources.dart';
import '../flags.dart';
import 'commands.dart';

/// Implementation for the 'pack' command.
/// The 'pack' command will scan the 'resources' directory under
/// your project root and  all subdirectories.
/// Each file that it finds is base64 encoded
/// and placed into dart library under:
///
/// ```
/// <project root>/lib/src/dcli/resources
/// ```
///
/// So the following resources:
/// ```text
/// <project root>/resources/
///             images/photo.png
///             data/zips/installer.zip
/// ```
///
/// Will be converted to:
///
/// ```text
/// <project root>/lib/src/resources/
///             images/photo_png.dart
///             data/zips/installer_zip.dart
/// ```
///
/// As part of the packing process DCli also creates a registry of the
/// resources packed.
/// This is done by creating a dart library called 'lib/src/dcli/resources/generated/registry.dart'.
/// The contents of the 'resources/generated/registry.dart' are of the form.
///
/// ```text
/// resources/generated/registry.dart
///
/// static const Map<String, PackedResource> resources = {
/// 'images/photo.png': PackedResource('images/photo.png', <library_name>),
/// 'data/zips/installer.zip': PackedResource('data/zips/installer.zip', '<library_name>)
/// };
///
/// Each of the resouces will be placed in a generated dart library of the form
/// lib/src/dcli/resources/generated/<uuid>.g.dart
///
/// ```

class PackCommand extends Command {
  ///
  PackCommand() : super(_commandName);

  static const String _commandName = 'pack';

  /// [arguments] contains path to clean
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    Resources().pack();
    return 0;
  }

  @override
  String usage() => 'pack';

  @override
  String description() => '''
Pack any files under <project root/lib/src/assets into a dart
library which can be unpacked at install time.''';

  @override
  List<String> completion(String word) => [word];

  @override
  List<Flag> flags() => [];
}
