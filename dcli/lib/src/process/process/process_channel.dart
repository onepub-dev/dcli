import 'dart:async';

class ProcessChannel {
  int get exitCode => throw UnimplementedError();

  static ProcessChannel pipe(
          Stream<List<int>> stdin, StreamSink<List<int>> sink) =>
      throw UnimplementedError();

  List<int> readStdout() => throw UnimplementedError();

  List<int> readStderr() => throw UnimplementedError();

  void writeToStdin(List<int> data) => throw UnimplementedError();
}


// // @dart=3.0

// // ignore_for_file: constant_identifier_names

// import 'dart:async';
// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:typed_data';

// import 'package:native_synchronization/mailbox.dart';

// import 'message.dart';
// // import 'mailbox.dart';
// import 'pipe_sync.dart';
// import 'process_in_isolate2.dart';
// // import 'process_sync.dart';

// /// Send and Receive data to/from a process
// /// running in an isolate using a pair of mailboxes.
// class ProcessChannel {
//   ProcessChannel()
//       : pipeMode = false,
//         mailboxToPrimaryIsolate = Mailbox(),
//         mailboxFromPrimaryIsolate = Mailbox();

//   /// Configures the channel to:
//   ///  * forward data from the passed [stdin] to the process
//   ///     running in the isolate.
//   ///  * write data from the process's stdout to [stdout]
//   /// stderr is still sent to the [stderrLines] - I don't like
//   /// this.
//   ProcessChannel.pipe(Stream<List<int>> stdin, Sink<List<int>> stdout)
//       : pipeMode = true,
//         mailboxToPrimaryIsolate = Mailbox(),
//         mailboxFromPrimaryIsolate = Mailbox() {
//     /// send data from stdin to the
//     /// isolates so it can pass
//     /// it to the process.
//     stdin.listen(writeToStdin);

//     _CallbackSink((line) {
//       MessageResponse.fromData(line)
//         ..onStdout(stdout.add)
//         ..onStderr(stderrLines.add)
//         ..onExit((exitCode) => _exitCode = exitCode);
//     });
//     // decoder = const Utf8Decoder().startChunkedConversion(splitter);
//   }

//   void _processMessageFromIsolate(List<int> data) {
//     MessageResponse.fromData(data)
//       ..onStdout((data) {
//         _logChannel('recieved stdout from isolate: ${utf8.decode(data)}');
//         stdoutLines.add(data);
//         stdoutController.sink.add(data);

//         // TODOhow does this data get to the progress because currently it isn't
//       })
//       ..onStderr((data) {
//         stderrLines.add(data);
//         stderrController.sink.add(data);
//       })
//       ..onExit((exitCode) => _exitCode = exitCode);
//     // });
//     // decoder = const Utf8Decoder().startChunkedConversion(splitter);
//   }

//   bool pipeMode;

//   /// Port used to send data to the spawned isolate.
//   late final SendPort sendPort;
//   late final Mailbox mailboxFromPrimaryIsolate;
//   final Mailbox mailboxToPrimaryIsolate;

//   // late final StringConversionSink splitter;
//   // late final ByteConversionSink decoder;

//   // final List<List<int>> stdoutLines = <List<int>>[];
//   // final List<List<int>> stderrLines = <List<int>>[];
//   // int get sendAddress => send.rawAddress;
//   // int get responseAddress => response.rawAddress;

//   int? _exitCode;
//   int? get exitCode => _exitCode;

//   bool get isRunning => _exitCode == null;

//   List<int>? readStdout() => _readLine(stdoutLines);

//   List<int>? readStderr() => _readLine(stderrLines);

//   // final stdoutController = StreamController<List<int>>();

//   void listenStdout(void Function(List<int>) callback) {
//     stdoutController.stream.listen((data) {
//       _logChannel(
//    'forwarding data to stdout listener length: ${data.length}');
//       callback(data);
//     });
//   }

//   // final stderrController = StreamController<List<int>>();

//   void listenStderr(void Function(List<int>) callback) {
//     stderrController.stream.listen(callback);
//   }

//   /// reads a line from the process.
//   /// If the process has exited and no more lines
//   /// are available then return null.
//   List<int>? _readLine(List<List<int>> lines) {
//     while (true) {
//       if (lines.isNotEmpty) {
//         return lines.removeAt(0);
//       }
//       // No lines remaining so fetch more from the mailbox.
//       if (_exitCode != null) {
//         return null;
//       }
//       _takeFromIsolate();
//     }
//   }

//   /// Will wait for the process to exit and return the exit
//   /// code.
//   int get waitForExitCode {
//     while (_exitCode == null) {
//       _takeFromIsolate();
//     }
//     return _exitCode!;
//   }

//   /// Stream stdin to [sink]
//   void streamStdin(Sink<String> sink) {}

//   /// Write [data] to the processes stdin.
//   void writeToStdin(List<int> data) {
//     // `TODO`: why are we using the sendPort rather than just he mailboxes.
//     sendPort.send(data);

//     /// check the data has been sent to the spawned process
//     /// before we return
//     final response = MessageResponse
// .fromData(mailboxFromPrimaryIsolate.take());

//     if (response.messageType != MessageType.ack) {
//       throw ProcessSyncException(
//           'Expecting a write confirmation: got $response');
//     }
//   }

//   /// fetch data from spawned isolate
//   void _takeFromIsolate() {
//     Uint8List bytes;

//     /// drain the mailbox
//     _logChannel('taking data from spawned isolates mailbox');
//     bytes = mailboxToPrimaryIsolate.take();
//     _logChannel(
//         'took data from spawned isolates mailbox: Size: ${bytes.length}');
//     _processMessageFromIsolate(bytes);
//     // decoder.add(bytes);

//     /// Tell the isolate that we are ready to recieve the next
//     /// message
//     // sendPort.send(WAKEUP);
//   }
// }

// /// Process messages coming from the isolate
// class _CallbackSink implements Sink<List<int>> {
//   _CallbackSink(this.cb);

//   final void Function(List<int> data) cb;

//   @override
//   void add(List<int> data) {
//     cb(data);
//   }

//   @override
//   void close() {}
// }

// void _logChannel(String message) {
//   if (debugIsolate) {
//     print('channel: $message');
//   }
// }
