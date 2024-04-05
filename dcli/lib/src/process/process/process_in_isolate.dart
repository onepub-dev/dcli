// `// ignore_for_file: unnecessary_lambdas

// import 'dart:async';
// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:typed_data';

// import 'package:dcli_core/dcli_core.dart';
// import 'package:native_synchronization/mailbox.dart';
// import 'package:native_synchronization/sendable.dart';

// import 'in_isolate/runner.dart';
// // import 'mailbox.dart';
// import 'message.dart';
// import 'native_calls.dart';
// import 'process_channel.dart';
// import 'process_settings.dart';
// import 'process_sync.dart';
// // import 'process_sync.dart';

// void startIsolate(ProcessSettings settings, ProcessChannel channel) {
//   _logPrimary('starting isolate');
//   unawaited(_startIsolate(settings, channel));

//   _logPrimary('waiting for isolate to spawn');

//   // final completer = Completer<Isolate>();
//   //Future.delayed(const Duration(seconds: 1), () {
//   /// The isolate is up and we are ready to recieve
//   channel.sendPort = _connectSendPort(channel);

//   // return completer.future;
// }

// SendPort _connectSendPort(ProcessChannel channel) {
//   /// take the initial message which contains
//   /// the channels sendPort id.
//   _logPrimary('try to take send port');
//   final msg = channel.mailboxFromPrimaryIsolate.take();

//   _logPrimary('took sendPort');

//   return NativeCalls.connectToPort(msg);
// }

// /// Starts an isolate that spawns the command.
// Future<Isolate> _startIsolate(
//         ProcessSettings processSettings, ProcessChannel channel) =>
//     Isolate.spawn<List<Sendable<Mailbox>>>((mailboxes) async {
//       /// We are now running in the isolate.
//       _logPrimary('isolate has started');
//       await Settings().setVerbose(enabled: true);

//       final mailboxFromPrimaryIsolate = mailboxes.first.materialize();
//       final mailboxToPrimaryIsolate = mailboxes.last.materialize();

//       final runner = ProcessRunner(processSettings);
//       _logPrimary('starting process ${processSettings.command} in isolate');
//       await runner.start();

//       final process = runner.process;

//       _logPrimary('process launched');

//       late StreamSubscription<List<int>> stdoutSub;
//       late StreamSubscription<List<int>> stderrSub;

//       _logPrimary('listen to recieve port');
//       // ignore: cancel_subscriptions
//       final port = ReceivePort()
//         ..listen((message) async {
//           _logPrimary('Isolate recieved message');
//           if (message case final Message message) {
//             if (message.type == MessageType.ack) {
//               stdoutSub.resume();
//               stderrSub.resume();
//             } else if (message.type == MessageType.stdin) {
//               // We received bytes from the primary isolate to write into stdin.

//               process!.stdin.add(message.payload);
//               await process.stdin.flush();

//               /// The tell the sender that we got their data and
//               /// sent it to stdin
//               await _postMessage(mailboxFromPrimaryIsolate, Message.ack());
//             } else {
//               throw ProcessSyncException('Wrong message: $message');
//             }
//           }
//         });

//       _logPrimary('getting port');

//       /// Tell the primary isolate what our native port address is
//       /// so it can send stuff to us sychronously.
//       final message = Message.port(port.sendPort);
//       _logPrimary('sending native send port');
//       await _postMessage(mailboxToPrimaryIsolate, message);

//       _logPrimary('post of native send port completed');

//       /// used to wait for the stdout stream to finish streaming
//       final stdoutStreamDone = Completer<void>();

//       /// subscribe to data the process writes to stdout and send
//       /// it back to the parent isolate
//       stdoutSub = process!.stdout.listen((data) {
//         stdoutSub.pause();
//         _logPrimary('writting to stdout: ${utf8.decode(data)}');
//         _postMessage(
//             mailboxToPrimaryIsolate, Message.stdout(data as Uint8List));
//         _logPrimary('write to stdout: complete');
//       }, onDone: () {
//         _logPrimary('stdout stream complete');
//         stdoutStreamDone.complete();
//       });

//       _logPrimary('listen of stdout completed');

//       /// used to wait for the stderr stream to finish streaming
//       final stderrStreamDone = Completer<void>();

//       /// subscribe to data the proccess writes to stderr and send
//       /// it back to the parent isolate
//       stderrSub = process.stderr.listen((data) {
//         stderrSub.pause();
//         _logPrimary('wrint to stderr');
//         final message = Message.stderr(data as Uint8List);
//         _postMessage(mailboxToPrimaryIsolate, message);
//       }, onDone: () {
//         _logPrimary('marking stderr in isolate done');
//         stderrStreamDone.complete();
//       });

//       _logPrimary('waiting in isolate for process to exit');

//       /// wait for the process to exit and all stream finish been written to.
//       await process.exitCode;
//       _logPrimary('process has exited');

//       await Future.wait<void>(
//           [stdoutStreamDone.future, stderrStreamDone.future]);

//       /// Wait for the process to shutdown and send the exitCode to
//       /// the parent isolate
//       final exitCode = await process.exitCode;
//       _logPrimary('process has exited with exitCode: $exitCode');

//       await _postMessage(mailboxToPrimaryIsolate, Message.exit(exitCode));

//       await stdoutSub.cancel();
//       await stderrSub.cancel();
//     },
//         // pass list of mailbox addresses into the isolate entry point.
//         List<Sendable<Mailbox>>.from([
//           channel.mailboxFromPrimaryIsolate.asSendable,
//           channel.mailboxToPrimaryIsolate.asSendable,
//         ]),
//         debugName: 'ProcessInIsolate');

// Future<void> _postMessage(Mailbox mailbox, Message message) async {
//   var tryPut = true;
//   while (tryPut) {
//     try {
//       tryPut = false;
//       _logPrimary('attempting to put message in mailbox');
//       mailbox.put(message.content);
//       _logPrimary('attempting to put message in mailbox - success');
//       // ignore: avoid_catching_errors
//     } on StateError catch (e) {
//       if (e.message == 'Mailbox is full') {
//         _logPrimary('mailbox is full sleeping for a bit');
//         tryPut = true;

//         /// yeild and give the mailbox read a chance to empty
//         /// the mailbox.
//         await Future.delayed(const Duration(seconds: 3), () {});
//         _logPrimary('woke from mailbox little put sleep.');
//       } else {
//         _logPrimary('StateError on postMesage $e');
//       }
//     }
//   }
// }

// void _logPrimary(String message) {
//   // _logPrimary(message);
// }
