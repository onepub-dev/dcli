import 'package:file_utils/file_utils.dart';

import 'package:path/path.dart' as p;

import 'dshell_function.dart';
import 'is.dart';
import 'settings.dart';
import '../util/log.dart';

/// Updates the last modified time stamp of a file.
///
/// ```dart
/// touch("fred.txt");
/// touch("fred.txt, create=true");
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
    if (Settings().debug_on) {
      Log.d("touch: ${p.absolute(path)} create: $create");
    }

    if (create == false && !exists(path)) {
      throw TouchException(
          "The file ${absolute(path)} does not exist. Did you mean to use touch(path, create: true) ?");
    }

    try {
      FileUtils.touch([path], create: true);
    } catch (e) {
      throw TouchException("An error occured touching ${absolute(path)}: $e");
    }
  }
}

class TouchException extends DShellFunctionException {
  TouchException(String reason) : super(reason);
}
