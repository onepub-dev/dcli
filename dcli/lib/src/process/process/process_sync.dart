// // @dart=3.0

// import 'dart:async';
// import 'dart:io';

// import 'package:dcli_core/dcli_core.dart';

// import 'process_channel.dart';
// import 'process_in_isolate2.dart';
// import 'process_settings.dart';

// /// Call a process synchronously
// class ProcessSync {
//   ProcessSync();

//   late final ProcessChannel _channel;

//   /// Read a line from stdout
//   List<int>? readStdout() => _channel.readStdout();

//   void listenStdout(void Function(List<int>) callback) {
//     _channel.listenStdout((data) {
//       _logIsolate('processSync recieved data from stdout channel');
//       callback(data);
//     });
//   }

//   void listenStderr(void Function(List<int>) callback) {
//     _channel.listenStderr((data) {
//       _logIsolate('processSync recieved data from stderr channel');
//       callback(data);
//     });
//   }

//   /// Read a line from stderr
//   List<int>? readStderr() => _channel.readStderr();

//   void write(List<int> data) => _channel.writeToStdin(data);

//   /// fetch the exit code of the process.
//   /// If the process has not yet exited then null will be returned.
//   int? get exitCode => _channel.exitCode;

//   /// Only returns once the process has exited and all
//   /// streams have been flushed from the isolate side.
//   /// This is no guarentee that the streams have been read
//   ///
//   int get waitForExitCode => _channel.waitForExitCode;

//   /// Run the given process as defined by [settings].
//   void run(ProcessSettings settings) {
//     _logIsolate('starting isolate');
//     _channel = ProcessChannel();

//     startIsolate2(settings, _channel);
//   }

//   /// Start the process but redirect stdout and stderr to
//   /// [stdout] and [stderr] respectively.
//   void pipe(ProcessSettings settings, Stream<List<int>> stdin,
//       Sink<List<int>> stdout) {
//     _channel = ProcessChannel.pipe(stdin, stdout);

//     startIsolate2(settings, _channel);
//   }

//   void writeLine(String s) {
//     write(s.codeUnits);
//   }
// }



// void _logIsolate(String message) {
//   // print(message);
// }
