import 'package:dcli_core/dcli_core.dart' as core;

import '../../dcli.dart';
import 'internal_progress.dart';

///
/// Returns count [lines] from the end of the file at [path].
///
/// ```dart
/// tail('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [TailException] exception if [path] is not a file.
///
TailProgress tail(String path, int lines) =>
    TailProgress._internal(path, lines);

class TailProgress extends InternalProgress {
  TailProgress._internal(this.path, this.lines);

  String path;
  int lines;

  /// Read lines from the head of the file.
  @override
  void forEach(LineAction action) {
    // waitForEx(
    //   core.tail(path, lines).listen((line) => action(line)).asFuture<String>(),

    var tstream = core.tail(path, lines);

    tstream.listen((line) => action(line)).asFuture<String>();

    waitForEx<String>();
  }
}

/// thrown when the [tail] function encounters an exception
class TailException extends core.DCliFunctionException {
  /// thrown when the [tail] function encounters an exception
  TailException(String reason) : super(reason);
}
