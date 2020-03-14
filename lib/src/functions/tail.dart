import 'package:dshell/src/util/circular_buffer.dart';

import 'function.dart';
import '../util/file_sync.dart';
import '../util/progress.dart';

import '../settings.dart';

import 'is.dart';

///
/// Returns count [lines] from the file at [path].
///
/// ```dart
/// tail('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [TailException] exception if [path] is not a file.
///
Progress tail(String path, int lines) => Tail().tail(path, lines);

class Tail extends DShellFunction {
  Progress tail(String path, int lines, {Progress progress}) {
    Settings().verbose('tail ${absolute(path)} lines: ${lines}');

    if (!exists(path)) {
      throw TailException('The path ${absolute(path)} does not exist.');
    }

    if (!isFile(path)) {
      throw TailException('The path ${absolute(path)} is not a file.');
    }

    try {
      progress ??= Progress.printStdOut();

      var buf = CircularBuffer<String>(lines);

      var file = FileSync(path);
      file.read((line) {
        buf.insert(line);

        return true;
      });

      buf.forEach((line) => progress.addToStdout(line));
    } catch (e) {
      throw TailException(
          'An error occured reading ${absolute(path)}. Error: $e');
    } finally {
      progress.close();
    }

    return progress;
  }
}

class TailException extends FunctionException {
  TailException(String reason) : super(reason);
}
