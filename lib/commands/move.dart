import 'dart:io';

import 'package:dshell/commands/command.dart';
import 'package:dshell/dshell.dart';

import '../util/log.dart';
import 'package:path/path.dart' as p;

import 'settings.dart';

///
/// Moves the file [from] to the location [to].
///
/// ```dart
/// createDir("/tmp/folder");
/// move("/tmp/fred.txt", "/tmp/folder/tom.txt");
/// ```
/// [from] must be a file.
///
/// [to] may be a file or a path.
///
/// If [to] is a file then a rename occurs.
///
/// if [to] is a path then [from] is moved to the given path.
///
/// If the move fails for any reason a [MoveException] is thrown.
///
void move(String from, String to) => Move().move(from, to);

class Move extends Command {
  void move(String from, String to) {
    if (Settings().debug_on) {
      Log.d("move ${absolute(from)} -> ${absolute(to)}");
    }

    String dest = to;

    if (isDirectory(to)) {
      dest = p.join(to, p.basename(from));
    }

    try {
      File(from).renameSync(dest);
    } catch (e) {
      throw MoveException(
          "The Move of ${absolute(from)} to ${absolute(dest)} failed. Error ${e}");
    }
  }
}

class MoveException extends CommandException {
  MoveException(String reason) : super(reason);
}
