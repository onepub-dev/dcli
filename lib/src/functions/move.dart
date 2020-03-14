import 'dart:io';

import 'function.dart';
import '../../dshell.dart';

import 'package:path/path.dart' as p;

///
/// Moves the file [from] to the location [to].
///
/// ```dart
/// createDir('/tmp/folder');
/// move('/tmp/fred.txt', '/tmp/folder/tom.txt');
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

class Move extends DShellFunction {
  void move(String from, String to) {
    Settings().verbose('move ${absolute(from)} -> ${absolute(to)}');

    var dest = to;

    if (isDirectory(to)) {
      dest = p.join(to, p.basename(from));
    }

    try {
      File(from).renameSync(dest);
    } catch (e) {
      throw MoveException(
          'The Move of ${absolute(from)} to ${absolute(dest)} failed. Error ${e}');
    }
  }
}

class MoveException extends FunctionException {
  MoveException(String reason) : super(reason);
}
