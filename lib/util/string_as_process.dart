import 'dart:async';
import 'dart:cli';
import 'dart:io';
import 'dart:convert';

import 'package:dshell/commands/command.dart';
import 'package:dshell/util/stack_trace_impl.dart';

typedef void LineAction(String line);

///
/// A set of String extensions that lets you
/// execute the contents of a string as a command line application.
///
extension StringAsProcess on String {
  ///
  /// Takes the contents of a string an executes it as a
  /// command line appliation.
  ///
  /// ```dart
  /// 'grep alabama regions.txt'.run
  /// ```
  /// Runs the command grep, but you won't see any output.
  ///
  /// ```dart
  /// 'grep alabama regions.txt'.run.forEach((line) => print(line));
  /// ```
  ///
  /// Runs grep and then uses the dart [forEach]  to print each line returned.
  ///
  Future<Stream<String>> run([LineAction lineAction]) async {
    StreamController<String> _controller = StreamController<String>();

    List<String> parts = this.split(" ");
    String cmd = parts[0];
    List<String> args = List();

    if (parts.length > 1) {
      args = parts.sublist(1);
    }

    print("${Directory.current}");

    print("cmd $cmd args: $args");

    Completer<bool> done = Completer<bool>();
    await Process.start(cmd, args, runInShell: false)
        .then((Process process) async {
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((data) {
        if (lineAction != null) {
          lineAction(data);
        }
        _controller.add(data);
      });

      await process.exitCode.then((exitCode) {
        if (exitCode != 0) {
          done.completeError(RunException(
              "The command [${this}] failed with exitCode: ${exitCode}"));
        } else {
          done.complete(true);
        }
      });
      // process.stdin.writeln('Hello, world!');
      // process.stdin.writeln('Hello, galaxy!');
      // process.stdin.writeln('Hello, universe!');
    });

    RunException exception;
    try {
      waitFor<bool>(done.future);
    } on AsyncError catch (e) {
      if (e.error is RunException) {
        exception = e.error as RunException;
      } else {
        rethrow;
      }
    }

    if (exception != null) {
      // recreate the exception so we have a full
      // stacktrace rather than the microtask
      // stacktrace the future leaves us with.
      StackTraceImpl stackTrace = StackTraceImpl();

      throw RunException.rebuild(exception, stackTrace);
    }

    return Future.value(_controller.stream);
  }

//   Future<Stream<String>> operator |(IOSink next) async {
//     return this.run.then((stream) {
//       //  next.addStream(stream);
//       // next.then<Stream<String>>((nextStream) {
//       //   stream.pipe(nextStream.asStream());
//       // });
//     });
//   }
// }

// void main() {
//   'cat pubspec.lock'.run.then((stream) {
//     stream.listen((data) {
//       print("listner $data");
//     });

//     ///'cat pubspec.lock' | 'head'.run;
//   });
}

class RunException extends CommandException {
  RunException(String reason) : super(reason);

  RunException.rebuild(RunException e, StackTraceImpl stackTrace)
      : super.rebuild(e, stackTrace);
}
