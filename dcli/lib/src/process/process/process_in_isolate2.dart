// ignore_for_file: unnecessary_lambdas, cascade_invocations

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:native_synchronization/mailbox.dart';
import 'package:native_synchronization/sendable.dart';
import 'package:stack_trace/stack_trace.dart';

// import 'mailbox.dart';
import '../../../dcli.dart';
import 'in_isolate/runner.dart';
import 'mailbox_extension.dart';
import 'message.dart';
import 'process_settings.dart';
// import 'process_sync.dart';

const debugIsolate = false;

void startIsolate2(ProcessSettings settings, Mailbox mailboxFromPrimaryIsolate,
    Mailbox mailboxToPrimaryIsolate) {
  _logPrimary('starting isolate');
  unawaited(_startIsolate(
      settings, mailboxFromPrimaryIsolate, mailboxToPrimaryIsolate));

  _logPrimary('waiting for isolate to spawn');
  // final message =
  //     MessageResponse.fromData(channel.mailboxToPrimaryIsolate.take());
  // if (message.messageCode != Message.msgAck) {
  //   printerr('Expected ACK on isolate start');
  // }
  // _logPrimary('recived ack that isolate started');
}

/// Starts an isolate that spawns the command.
Future<Isolate> _startIsolate(ProcessSettings processSettings,
        Mailbox mailboxFromPrimaryIsolate, Mailbox mailboxToPrimaryIsolate) =>
    Isolate.spawn<List<Sendable<Mailbox>>>((mailboxes) async {
      // await mailboxToPrimaryIsolate.postMessage(Message.exit(1));
      final mailboxFromPrimaryIsolate = mailboxes.first.materialize();
      final mailboxToPrimaryIsolate = mailboxes.last.materialize();

      try {
        /// We are now running in the isolate.
        _logIsolate('started');
        // `TODO`: this causes output to stdout which probably isn't desirable.
        Settings().setVerbose(enabled: false);

        await mailboxToPrimaryIsolate.postMessage(Message.ack());
        _logIsolate('sent ack');

        final runner = ProcessRunner(processSettings);
        _logIsolate('starting process ${processSettings.command} in isolate');
        await runner.start();

        final process = runner.process;

        _logIsolate('process launched');

        late StreamSubscription<List<int>> stdoutSub;
        late StreamSubscription<List<int>> stderrSub;

        _logIsolate('listen to recieve port');
        // ignore: cancel_subscriptions
        final port = ReceivePort()
          ..listen((message) async {
            _logIsolate(' recieved message');
            if (message is List<int> || message is String) {
              // We received bytes from the primary isolate to write into stdin.
              if (message is String) {
                message = utf8.encode(message);
              }
              process!.stdin.add(message as List<int>);
              await process.stdin.flush();

              // /// The tell the sender that we got their data and
              // /// sent it to stdin
              // await mailboxToPrimaryIsolate.postMessage(Message.ack());
            } else {
              throw ProcessSyncException('Wrong message: $message');
            }
          });

        /// Tell the primary isolate what our native port address is
        /// so it can send stuff to us sychronously.
        _logIsolate('sending native send port');
        await mailboxToPrimaryIsolate.postMessage(Message.port(port.sendPort));

        _logIsolate('post of native send port completed');

        /// used to wait for the stdout stream to finish streaming
        final stdoutStreamDone = Completer<void>();

        /// subscribe to data the process writes to stdout and send
        /// it back to the parent isolate
        stdoutSub = process!.stdout.listen((data) {
          stdoutSub.pause();
          _logIsolate('writing to stdout: ${utf8.decode(data)}');
          mailboxToPrimaryIsolate
              .postMessage(Message.stdout(data as Uint8List));
          _logIsolate('write to stdout: success');
          stdoutSub.resume();
        }, onDone: () {
          _logIsolate('marking stdout stream completed');
          stdoutStreamDone.complete();
        });

        _logIsolate('listen of stdout completed');

        /// used to wait for the stderr stream to finish streaming
        final stderrStreamDone = Completer<void>();

        /// subscribe to data the proccess writes to stderr and send
        /// it back to the parent isolate
        stderrSub = process.stderr.listen((data) {
          stderrSub.pause();
          _logIsolate('writing to stderr');
          final message = Message.stderr(data as Uint8List);
          mailboxToPrimaryIsolate.postMessage(message);
          stderrSub.resume();
        }, onDone: () {
          _logIsolate('marking stderr stream completed');
          stderrStreamDone.complete();
        });

        _logIsolate('waiting in isolate for process to exit');

        /// wait for the process to exit and all stream finish been written to.
        final exitCode = await process.exitCode;
        _logIsolate('process has exited with exitCode: $exitCode');

        await Future.wait<void>(
            [stdoutStreamDone.future, stderrStreamDone.future]);

        _logIsolate('streams are done');

        await mailboxToPrimaryIsolate.postMessage(Message.exit(exitCode));

        await stdoutSub.cancel();
        await stderrSub.cancel();
      } on RunException catch (e, _) {
        print('exeception throw');
        _logIsolate('Exception caught: $e');
        await mailboxToPrimaryIsolate.postMessage(Message.runException(e));
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e, st) {
        await mailboxToPrimaryIsolate.postMessage(Message.runException(
            RunException.fromException(
                e, processSettings.command, processSettings.args,
                stackTrace: Trace.from(st))));
      }
      _logIsolate('Isolate is exiting');
    },
        // pass list of mailbox addresses into the isolate entry point.
        List<Sendable<Mailbox>>.from([
          mailboxFromPrimaryIsolate.asSendable,
          mailboxToPrimaryIsolate.asSendable,
        ]),
        debugName: 'ProcessInIsolate');

void _logPrimary(String message) {
  if (debugIsolate) {
    print('primary: $message');
  }
}

void _logIsolate(String message) {
  if (debugIsolate) {
    print('isolate: $message');
  }
}
