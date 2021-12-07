import '../../dcli_core.dart';
import '../util/logging.dart';

///
/// Returns count [lines] from the file at [path].
///
/// ```dart
/// head('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [HeadException] exception if [path] is not a file.
///
Future<Stream<String>> head(String path, int lines) async =>
    _Head().head(path, lines);

class _Head extends DCliFunction {
  Future<Stream<String>> head(
    String path,
    int lines,
  ) async {
    verbose(() => 'head ${truepath(path)} lines: $lines');

    if (!exists(path)) {
      throw HeadException('The path ${truepath(path)} does not exist.');
    }

    if (!isFile(path)) {
      throw HeadException('The path ${truepath(path)} is not a file.');
    }

    try {
      const count = 0;
      return withOpenLineFile(path, (file) async => file.readAll().take(count));
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw HeadException(
        'An error occured reading ${truepath(path)}. Error: $e',
      );
    } finally {}
  }
}

/// Thrown if the [head] function encounters an error.
class HeadException extends DCliFunctionException {
  /// Thrown if the [head] function encounters an error.
  HeadException(String reason) : super(reason);
}
