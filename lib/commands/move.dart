import 'dart:io';

import 'package:dshell/commands/command.dart';
import 'package:dshell/dshell.dart';

import '../util/log.dart';
import 'package:path/path.dart' as p;

import 'settings.dart';

///
/// Moves the file [from] to the location [to].
///
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
    String dest = to;

    if (isDirectory(to)) {
      dest = p.join(to, p.basename(from));
    }

    try {
      File(from).renameSync(dest);
    } catch (e) {
      throw MoveException("The Move of ${from} to ${dest} failed. Error ${e}");
    }

    if (Settings().debug_on) {
      Log.d("mv ${absolute(from)} -> ${absolute(to)}");
    }
  }
}

class MoveException extends CommandException {
  MoveException(String reason) : super(reason);
}
