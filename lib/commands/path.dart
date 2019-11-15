import 'package:dshell/commands/command.dart';
import 'package:file_utils/file_utils.dart';

/// Removes the directory component and extension from the [path] returning
/// just the filename sans the extension.
///
/// '''dart
/// basename("/fred/john.jpg")
///   > john
/// ```
String basename(String path) => Path().basename(path);

/// Returns the filename component of [path] by
/// removing the directory component.
/// ''' dart
/// filename("/fred/john.jpg")
///   > john.jpg
/// ```
String filename(String path) => Path().filename(path);

/// Returns the filename extension without the dot.
///
/// ''' dart
/// filename("/fred/john.jpg")
///   > jpg
/// ```
String extension(String path) => Path().extension(path);

///
/// Returns the fully qualified path of [path].
///
/// '''dart
/// absolute("fred");
///   > /home/fred
String absolute(String path) => Path().absolute(path);

/// Returns the canonicalized form of [path] by removing
/// any relative path segments and returning an
/// absolute path.
///
/// ```dart
/// canonicalize("../../fred");
///  > /home/fred
///
String canonicalize(String path) => Path().canonicalize(path);

class Path extends Command {
  String filename(String path) => FileUtils.basename(path);
  String canonicalize(String path) => FileUtils.fullpath(path);

  String basename(String path) {
    String extension = this.extension(path);
    String filename = this.filename(path);
    String basename = filename.substring(0, filename.length - extension.length);

    return basename;
  }

  String extension(String path) {
    String extension = "";

    int index = path.lastIndexOf(".");
    if (index != -1) {
      extension = path.substring(index);
    }
    return extension;
  }
}
