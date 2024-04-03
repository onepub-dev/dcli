// ignore_for_file: unnecessary_lambdas

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dcli_core/dcli_core.dart';
import 'package:native_synchronization/mailbox.dart';
import 'package:native_synchronization/sendable.dart';

import 'in_isolate/runner.dart';
// import 'mailbox.dart';
import 'message.dart';
import 'native_calls.dart';
import 'process_channel.dart';
import 'process_settings.dart';
import 'process_sync.dart';
// import 'process_sync.dart';

Future<Isolate> startIsolate(ProcessSettings settings, ProcessChannel channel) {
  print('starting isolate');
  final spawning = _startIsolate(settings, channel);

  print('waiting for isolate to spawn');

  final completer = Completer<Isolate>();
  spawning.then((isolate) {
    print('isolate has been spawned');
    //Future.delayed(const Duration(seconds: 1), () {
    /// The isolate is up and we are ready to recieve
    channel.sendPort = _connectSendPort(channel);
    print('got send channel');
    completer.complete(isolate);
  });

  return completer.future;
}

SendPort _connectSendPort(ProcessChannel channel) {
  /// take the initial message which contains
  /// the channels sendPort id.
  print('try to take send port');
  final msg = channel.send.take();

  print('took sendPort');

  return NativeCalls.connectToPort(msg);
}

/// Starts an isolate that spawns the command.
Future<Isolate> _startIsolate(
        ProcessSettings processSettings, ProcessChannel channel) =>
    Isolate.spawn<List<Sendable<Mailbox>>>((mailboxes) async {
      /// We are now running in the isolate.
      print('isoalte has started');
      await Settings().setVerbose(enabled: true);

      final sendMailbox = mailboxes.first.materialize();
      final responseMailbox = mailboxes.last.materialize();

      final runner = ProcessRunner(processSettings);
      print('starting process ${processSettings.command} in isolate');
      await runner.start();

      final process = runner.process;

      print('process launched');

      late StreamSubscription<List<int>> stdoutSub;
      late StreamSubscription<List<int>> stderrSub;

      print('listen to recieve port');
      // ignore: cancel_subscriptions
      final port = ReceivePort()
        ..listen((message) async {
          print('Isolate recieved message');
          if (message == ProcessChannel.WAKEUP) {
            stdoutSub.resume();
            stderrSub.resume();
          } else if (message is List<int> || message is String) {
            // We received bytes from the primary isolate to write into stdin.
            if (message is String) {
              message = utf8.encode(message);
            }
            process!.stdin.add(message as List<int>);
            await process.stdin.flush();

            /// The tell the sender that we got their data and
            /// sent it to stdin
            await _postMessage(sendMailbox, Message.received());
          } else {
            throw ProcessSyncException('Wrong message: $message');
          }
        });

      print('getting port');

      /// Tell the primary isolate what our native port address is
      /// so it can send stuff to us sychronously.
      final message = Message.port(port.sendPort);
      print('sending native send port');
      await _postMessage(responseMailbox, message);

      print('post of native send port completed');

      /// used to wait for the stdout stream to finish streaming
      final stdoutStreamDone = Completer<void>();

      /// subscribe to data the process writes to stdout and send
      /// it back to the parent isolate
      stdoutSub = process!.stdout.listen((data) {
        stdoutSub.pause();
        print('writting to stdout: ${utf8.decode(data)}');
        _postMessage(responseMailbox, Message.stdout(data as Uint8List));
        print('write to stdout: complete');
      }, onDone: () {
        print('stdout stream complete');
        stdoutStreamDone.complete();
      });

      print('listen of stdout completed');

      /// used to wait for the stderr stream to finish streaming
      final stderrStreamDone = Completer<void>();

      /// subscribe to data the proccess writes to stderr and send
      /// it back to the parent isolate
      stderrSub = process.stderr.listen((data) {
        stderrSub.pause();
        print('wrint to stderr');
        final message = Message.stderr(data as Uint8List);
        _postMessage(responseMailbox, message);
      }, onDone: () {
        print('marking stderr in isolate done');
        stderrStreamDone.complete();
      });

      print('waiting in isolate for process to exit');

      /// wait for the process to exit and all stream finish been written to.
      await process.exitCode;
      print('process has exited');

      await Future.wait<void>(
          [stdoutStreamDone.future, stderrStreamDone.future]);

      /// Wait for the process to shutdown and send the exitCode to
      /// the parent isolate
      final exitCode = await process.exitCode;
      print('process has exited with exitCode: $exitCode');

      await _postMessage(responseMailbox, Message.exit(exitCode));

      await stdoutSub.cancel();
      await stderrSub.cancel();
    },
        // pass list of mailbox addresses into the isolate entry point.
        List<Sendable<Mailbox>>.from([
          channel.send.asSendable,
          channel.response.asSendable,
        ]),
        debugName: 'ProcessInIsolate');

Future<void> _postMessage(Mailbox mailbox, Message message) async {
  var tryPut = true;
  while (tryPut) {
    try {
      tryPut = false;
      print('attempting to put message in mailbox');
      mailbox.put(message.content);
      print('attempting to put message in mailbox - success');
      // ignore: avoid_catching_errors
    } on StateError catch (e) {
      if (e.message == 'Mailbox is full') {
        print('mailbox is full sleeping for a bit');
        tryPut = true;

        /// yeild and give the mailbox read a chance to empty
        /// the mailbox.
        await Future.delayed(const Duration(seconds: 3), () {});
        print('woke from mailbox little put sleep.');
      } else {
        print('StateError on postMesage $e');
      }
    }
  }
}
