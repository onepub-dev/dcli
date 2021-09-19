import 'package:dcli_core/dcli_core.dart' as core hide HeadException;

import '../../dcli.dart';

export 'package:dcli_core/dcli_core.dart' show HeadException;

///
/// Returns count [lines] from the file at [path].
///
/// ```dart
/// head('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [HeadException] exception if [path] is not a file.
///
Progress head(String path, int lines) {
  final capture = Progress.capture();
  core.head(path, lines).then((stream) => stream.listen(capture.addToStdout));
  return capture;
}
