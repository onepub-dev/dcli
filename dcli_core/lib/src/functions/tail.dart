import 'dart:async';

import 'package:circular_buffer/circular_buffer.dart';

import '../util/line_file.dart';
import '../util/logging.dart';
import '../util/truepath.dart';
import 'dcli_function.dart';
import 'is.dart';

///
/// Returns count [lines] from the end of the file at [path].
///
/// ```dart
/// tail('/var/log/syslog', 10).forEach((line) => print(line));
/// ```
///
/// Throws a [TailException] exception if [path] is not a file.
///
Stream<String> tail(String path, int lines) => _Tail().tail(path, lines);

class _Tail extends DCliFunction {
  Stream<String> tail(
    String path,
    int lines,
  ) async* {
    verbose(() => 'tail ${truepath(path)} lines: $lines');

    if (lines < 1) {
      throw TailException('lines must be >= 1');
    }

    if (!exists(path)) {
      throw TailException('The path ${truepath(path)} does not exist.');
    }

    if (!isFile(path)) {
      throw TailException('The path ${truepath(path)} is not a file.');
    }

    /// circbuffer requires a min size of 2 so we
    /// add one to make certain it is always greater than one
    /// and then adjust later.
    final buffer = CircularBuffer<String>(lines + 1);
    final done = Completer<bool>();
    try {
      await withOpenLineFile(path, (file) async {
        late final StreamSubscription<String>? sub;
        try {
          sub = file.readAll().listen((line) async {
            sub!.pause();
            buffer.add(line);
            sub.resume();
          }, onDone: () => done.complete(true));
          await done.future;
        } finally {
          if (sub != null) {
            await sub.cancel();
          }
        }
      });
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      throw TailException(
        'An error occured reading ${truepath(path)}. Error: $e',
      );
    }

    await done.future;

    final lastLines = buffer.toList();

    /// adjust the buffer by stripping extra line.
    if (buffer.isFilled) {
      lastLines.removeAt(0);
    }

    // return the last [lines] which will
    // be left in the buffer.
    for (final line in lastLines) {
      yield line;
    }
  }
}

/// thrown when the [tail] function encounters an exception
class TailException extends DCliFunctionException {
  /// thrown when the [tail] function encounters an exception
  TailException(String reason) : super(reason);
}
