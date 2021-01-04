import '../settings.dart';

import '../util/file_sync.dart';
import '../util/progress.dart';

import 'function.dart';

import 'is.dart';

///
/// Returns count [lines] from the file at [path].
///
/// ```dart
/// head('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [HeadException] exception if [path] is not a file.
///
Progress head(String path, int lines) => _Head().head(path, lines);

class _Head extends DCliFunction {
  Progress head(String path, int lines, {Progress? progress}) {
    Settings().verbose('head ${absolute(path)} lines: $lines');

    if (!exists(path)) {
      throw HeadException('The path ${absolute(path)} does not exist.');
    }

    if (!isFile(path)) {
      throw HeadException('The path ${absolute(path)} is not a file.');
    }

    try {
      progress ??= Progress.printStdOut();
      var count = 0;
      final file = FileSync(path);
      file.read((line) {
        progress!.addToStdout(line);
        count++;
        if (count >= lines) {
          return false;
        }
        return true;
      });
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw HeadException(
          'An error occured reading ${absolute(path)}. Error: $e');
    } finally {
      progress!.close();
    }

    return progress;
  }
}

/// Thrown if the [head] function encounters an error.
class HeadException extends FunctionException {
  /// Thrown if the [head] function encounters an error.
  HeadException(String reason) : super(reason);
}
