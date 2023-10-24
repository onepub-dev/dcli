// @dart=3.0

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dcli_core/dcli_core.dart';

import 'in_isolate/runner.dart';
import 'mailbox.dart';
import 'message.dart';
import 'native_calls.dart';
import 'process_channel.dart';
import 'settings.dart';

/// Call a process synchronously
class ProcessSync {
  ProcessSync();

  late final ProcessChannel _channel;

  /// Read a line from stdout
  String readStdout() => _channel.readStdout();

  /// Read a line from stderr
  String readStderr() => _channel.readStderr();

  void write(String line) => _channel.write(line);

  /// fetch the exit code of the process.
  /// If the process has not yet exited then null will be returned.
  int? get exitCode => _channel.exitCode;

  /// Run the given process as defined by [settings].
  void run(ProcessSettings settings) {
    _channel = ProcessChannel();

    startIsolate(settings);

    /// The isolate is up and we and ready to recieve
    _channel.sendPort = _connectSendPort();
  }

  SendPort _connectSendPort() {
    /// take the initial message which contains
    /// the channels sendPort id.
    final msg = _channel.send.takeOne();
    return NativeCalls.connectToPort(msg);
  }

  void startIsolate(ProcessSettings processSettings) {
    unawaited(Isolate.spawn((mailboxAddrs) async {
      final sendMailbox = Mailbox.fromAddress(mailboxAddrs[0]);
      final responseMailbox = Mailbox.fromAddress(mailboxAddrs[1]);

      final runner = ProcessRunner(processSettings);
      await runner.start();

      final process = runner.process!;

      late StreamSubscription<List<int>> stdoutSub;
      late StreamSubscription<List<int>> stderrSub;

      // ignore: cancel_subscriptions
      final port = ReceivePort()
        ..listen((message) async {
          if (message == ProcessChannel.WAKEUP) {
            stdoutSub.resume();
            stderrSub.resume();
          } else if (message is List<int> || message is String) {
            // We received bytes to write into stdin.
            if (message is String) {
              message = utf8.encode(message);
            }
            process.stdin.add(message as List<int>);
            await process.stdin.flush();

            /// The tell the sender that we go their data and
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

      /// subscribe to data the process writes to standard OUT and send
      /// it back to the parent isolate
      stdoutSub = process.stdout.listen((data) {
        stdoutSub.pause();
        responseMailbox.respond(Message.stdout(data as Uint8List).message);
      });

      /// subscribe to data the proccess writes to standard ERR and send
      /// it back to the parent isolate
      stderrSub = process.stderr.listen((data) {
        stderrSub.pause();
        responseMailbox.respond(Message.stderr(data as Uint8List).message);
      });

      /// Wait for the process to shutdown and send the exitCode to
      /// the parent isolate
      final exitCode = await process.exitCode;
      responseMailbox.respond(Message.exit(exitCode).message);

      await stdoutSub.cancel();
      await stderrSub.cancel();
    }, [
      _channel.sendAddress,
      _channel.responseAddress,
    ]));
  }
}

class ProcessSyncException extends DCliException {
  ProcessSyncException(super.message);
}
