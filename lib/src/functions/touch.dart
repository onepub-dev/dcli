import 'package:file_utils/file_utils.dart';

import 'package:path/path.dart' as p;

import '../settings.dart';
import 'dshell_function.dart';
import 'is.dart';
import '../util/log.dart';

/// Updates the last modified time stamp of a file.
///
/// ```dart
/// touch('fred.txt');
/// touch('fred.txt, create=true');
/// ```
///
///
/// If [create] is true and the file doesn't exist
/// it will be created.
///
/// If [create] is false and the file doesn't exist
/// a [TouchException] will be thrown.
///
/// [create] is false by default.
void touch(String path, {bool create = false}) =>
    Touch().touch(path, create: create);

class Touch extends DShellFunction {
  void touch(String path, {bool create = false}) {
    var absolute = p.absolute(path);

    if (Settings().debug_on) {
      Log.d('touch: ${absolute} create: $create');
    }

    if (!exists(p.dirname(absolute))) {
      throw TouchException(
          'The directory tree above ${absolute} does not exist. Create the tree and try again.');
    }
    if (create == false && !exists(path)) {
      throw TouchException(
          'The file ${absolute} does not exist. Did you mean to use touch(path, create: true) ?');
    }

    try {
      if (!FileUtils.touch([path], create: true)) {
        throw TouchException(
            'Unable to touch file ${absolute}: check permissions');
      }
    } catch (e) {
      throw TouchException('An error occured touching ${absolute}: $e');
    }
  }
}

class TouchException extends DShellFunctionException {
  TouchException(String reason) : super(reason);
}
