import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'in_isolate/runner.dart';
import 'mailbox.dart';
import 'message.dart';
import 'native_calls.dart';
import 'process_channel.dart';
import 'process_settings.dart';
import 'process_sync.dart';

void startIsolate(ProcessSettings settings, ProcessChannel channel) {
  print('starting isolate');
  _startIsolate(settings, channel);
  print('isolate started - getting send channel');

  /// The isolate is up and we are ready to recieve
  channel.sendPort = _connectSendPort(channel);
  print('got send channel');
}

SendPort _connectSendPort(ProcessChannel channel) {
  /// take the initial message which contains
  /// the channels sendPort id.
  final msg = channel.send.takeOneMessage();
  return NativeCalls.connectToPort(msg);
}

/// Starts an isolate that spawns the command.
void _startIsolate(ProcessSettings processSettings, ProcessChannel channel) {
  unawaited(Isolate.spawn((mailboxAddrs) async {
    print('isoalte has started');

    /// This code runs in the isolate.
    final sendMailbox = Mailbox.fromAddress(mailboxAddrs[0]);
    final responseMailbox = Mailbox.fromAddress(mailboxAddrs[1]);

    final runner = ProcessRunner(processSettings);
    print('starting process ${processSettings.command} in isolate');
    await runner.start();

    final process = runner.process;

    late StreamSubscription<List<int>> stdoutSub;
    late StreamSubscription<List<int>> stderrSub;

    // ignore: cancel_subscriptions
    final port = ReceivePort()
      ..listen((message) async {
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
          sendMailbox.respond(Uint8List.fromList([ProcessChannel.RECEIVED]));
        } else {
          throw ProcessSyncException('Wrong message: $message');
        }
      });

    /// Tell the primary isolate what our native port address is
    /// so it can send stuff to use sychronously.
    final msg = Int64List(1)..[0] = port.sendPort.nativePort;
    sendMailbox.respond(msg.buffer.asUint8List());

    /// used to wait for the stdout stream to finish streaming
    final stdoutStreamDone = Completer<void>();

    /// subscribe to data the process writes to stdout and send
    /// it back to the parent isolate
    stdoutSub = process!.stdout.listen((data) {
      stdoutSub.pause();
      print('writting to stdout: ${utf8.decode(data)}');
      responseMailbox.respond(Message.stdout(data as Uint8List).message);
    }, onDone: () {
      stdoutStreamDone.complete();
      print('marking stdout in isolate done');
    });

    /// used to wait for the stderr stream to finish streaming
    final stderrStreamDone = Completer<void>();

    /// subscribe to data the proccess writes to stderr and send
    /// it back to the parent isolate
    stderrSub = process.stderr.listen((data) {
      stderrSub.pause();
      responseMailbox.respond(Message.stderr(data as Uint8List).message);
    }, onDone: () {
      stderrStreamDone.complete();
      print('marking stderr in isolate done');
    });

    print('waiting in isolate for process to exit');

    /// wait for the process to exit and all stream finish been written to.
    await Future.wait<void>([process.exitCode]);
    print('process has exited');

    await Future.wait<void>([stdoutStreamDone.future, stderrStreamDone.future]);

    /// Wait for the process to shutdown and send the exitCode to
    /// the parent isolate
    final exitCode = await process.exitCode;
    print('process has exited with exitCode: $exitCode');
    responseMailbox.respond(Message.exit(exitCode).message);

    await stdoutSub.cancel();
    await stderrSub.cancel();
  },
      // pass list of mailbox addresses into the isolate entry point.
      [
        channel.sendAddress,
        channel.responseAddress,
      ]));
}
