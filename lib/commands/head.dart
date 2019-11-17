import 'package:dshell/commands/command.dart';
import 'package:dshell/util/file_sync.dart';
import 'package:dshell/util/runnable_process.dart';

import '../util/log.dart';

import 'is.dart';
import 'settings.dart';

///
/// Returns count [lines] from the file at [path].
///
/// Throws a [HeadException] exception if [path] is not a file.
///
void head(String path, int lines, LineAction lineAction) =>
    Head().head(path, lines, lineAction);

class Head extends Command {
  void head(String path, int lines, LineAction lineAction) {
    if (Settings().debug_on) {
      Log.d("head ${absolute(path)} lines: ${lines}");
    }

    if (!exists(path)) {
      throw HeadException("The path ${absolute(path)} does not exist.");
    }

    if (!isFile(path)) {
      throw HeadException("The path ${absolute(path)} is not a file.");
    }

    try {
      int count = 0;
      FileSync file = FileSync(path);
      file.read((line) {
        lineAction(line);
        count++;
        if (count >= lines) {
          return false;
        }
        return true;
      });
    } catch (e) {
      throw HeadException(
          "An error occured reading ${absolute(path)}. Error: $e");
    }
  }
}

class HeadException extends CommandException {
  HeadException(String reason) : super(reason);
}
