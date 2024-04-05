// @dart=3.0

import 'package:dcli_core/dcli_core.dart';

import 'process_channel.dart';
import 'process_settings.dart';

/// Call a process synchronously
class PipeSync {
  PipeSync();

  late final ProcessChannel _lhsChannel;
  late final ProcessChannel _rhsChannel;

  /// Read a line from stdout
  List<int>? readStdout() => _rhsChannel.readStdout();

  /// Read a line from stderr
  List<int>? readStderr() => _rhsChannel.readStderr();

  void write(List<int> data) => _lhsChannel.writeToStdin(data);

  /// fetch the exit code of the process.
  /// If the process has not yet exited then null will be returned.
  /// TODO: we have two processes here so what
  /// exit code do we return?
  int? get exitCode => _rhsChannel.exitCode;

  /// Run the two given process as defined by [lhsSettings]
  /// (left-hand-side settings) and [rhsSettings] (right-hand-side settings).
  /// piping the input from the [lhsSettings] process into the [rhsSettings]
  /// process.
  ///
  /// bash pipes don't normally pipe stderr so for the
  /// moment neither will we.
  void run(ProcessSettings lhsSettings, ProcessSettings rhsSettings) {
    // final lhsController = StreamController<List<int>>();

    // // `TODO`(bsutton): channel for stderr - maybe see the about
    // ///  comment about bash
    // final _lhsChannel = ProcessChannel.pipe(io.stdin, lhsController.sink);
    // final _rhsChannel = ProcessChannel.pipe(lhsController.stream, io.stdout);

    // startIsolate2(lhsSettings, _lhsChannel);
    // startIsolate2(rhsSettings, _rhsChannel);
  }

  /// Start the process but redirect stdout and stderr to
  /// [stdout] and [stderr] respectively.
  // void pipe(
  //     ProcessSettings settings, Sink<String> stdout, Sink<String> stderr) {
  //   _channel = ProcessChannel.pipe(stdout, stderr);

  //   _start(settings);
  // }
}

class ProcessSyncException extends DCliException {
  ProcessSyncException(super.message);
}
