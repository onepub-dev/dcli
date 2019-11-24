import 'package:dshell/functions/function.dart';

import 'package:path/path.dart' as p;

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

///
/// Returns the parent directory of the given path.
String parent(String path) => Path().parent(path);

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

/// Delegate to Path package
/// Joins the given path parts into a single path using the current platform's [separator]. Example:
///
/// p.join('path', 'to', 'foo'); // -> 'path/to/foo'
/// If any part ends in a path separator, then a redundant separator will not be added:
///
/// p.join('path/', 'to', 'foo'); // -> 'path/to/foo
/// If a part is an absolute path, then anything before that will be ignored:
///
/// p.join('path', '/to', 'foo'); // -> '/to/foo'
String join(String part1,
        [String part2,
        String part3,
        String part4,
        String part5,
        String part6,
        String part7,
        String part8]) =>
    Path().join(part1, part2, part3, part4, part5, part6, part7, part8);

class Path extends DShellFunction {
  String filename(String path) => p.basename(path);
  String canonicalize(String path) => p.canonicalize(path);

  String basename(String path) {
    String extension = this.extension(path);
    String filename = this.filename(path);
    String basename =
        filename.substring(0, filename.length - (extension.length + 1));

    return basename;
  }

  /// Returns the parent directory of path.
  String parent(String path) {
    String canon = p.canonicalize(path);
    return p.dirname(canon);
  }

  String join(String part1,
      [String part2,
      String part3,
      String part4,
      String part5,
      String part6,
      String part7,
      String part8]) {
    return p.join(part1, part2, part3, part4, part5, part6, part7, part8);
  }

  String extension(String path) {
    String extension = "";

    int index = path.lastIndexOf(".");
    if (index != -1) {
      extension = path.substring(index + 1);
    }
    return extension;
  }
}
