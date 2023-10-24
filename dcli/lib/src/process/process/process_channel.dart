// @dart=3.0

// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'mailbox.dart';
import 'message.dart';
import 'synchronous.dart';

/// Send and Receive data to/from a process
/// running in an isolate using a pair of mailboxes.
class ProcessChannel {
  ProcessChannel()
      : response = Mailbox(),
        send = Mailbox() {
    splitter =
        const LineSplitter().startChunkedConversion(_CallbackSink((line) {
      MessageResponse.fromLine(line)
        ..onStdout(stdoutLines.add)
        ..onStderr(stdoutLines.add)
        ..onExit((exitCode) => _exitCode = exitCode);
    }));
    decoder = const Utf8Decoder().startChunkedConversion(splitter);
  }

  // Used when sending a request to to the isolate
  // to send use more data.
  static const int WAKEUP = 1;

  /// Used by the isolate to confirm it
  /// received the data and to honour
  /// the mailboxes required send one/recieve
  /// one protocol
  static const int RECEIVED = 1;

  /// Port used to send data to the isolate.
  late final SendPort sendPort;
  late final Mailbox send;
  final Mailbox response;

  late final StringConversionSink splitter;
  late final ByteConversionSink decoder;

  final List<String> stdoutLines = <String>[];
  final List<String> stderrLines = <String>[];

  int get sendAddress => send.rawAddress;
  int get responseAddress => response.rawAddress;

  int? _exitCode;
  int? get exitCode => _exitCode;

  bool get isRunning => _exitCode == null;

  String readStdout() => readLine(stdoutLines);

  String readStderr() => readLine(stderrLines);

  String readLine(List<String> lines) {
    while (true) {
      if (lines.isNotEmpty) {
        return lines.removeAt(0);
      }
      // No lines remaining so fetch more from the mailbox.
      _fetch();
    }
  }

  /// Write [data] to the processes stdin.
  void write(String data) {
    sendPort.send(data);

    /// check the data has been sent to the spawned process
    /// before we return
    final response = send.takeOne();
    if (response.isEmpty || response[0] != RECEIVED) {
      throw ProcessSyncException(
          'Expecting a write confirmation: got $response');
    }
  }

  void _fetch() {
    Uint8List bytes;

    /// drain the mailbox
    bytes = response.takeOne();
    decoder.add(bytes);

    /// Tell the isolate that we are ready to recieve the next
    /// message
    sendPort.send(WAKEUP);
  }
}

/// Process messages coming from the isolate
class _CallbackSink implements Sink<String> {
  _CallbackSink(this.cb);

  final void Function(String line) cb;

  @override
  void add(String data) {
    cb(data);
  }

  @override
  void close() {}
}
