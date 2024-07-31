// ignore_for_file: unnecessary_lambdas, cascade_invocations

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:native_synchronization_temp/mailbox.dart';
import 'package:stack_trace/stack_trace.dart';

// import 'mailbox.dart';
import '../../../dcli.dart';
import '../../util/runnable_process.dart';
import 'in_isolate/process_runner.dart';
import 'isolate_channel.dart';
import 'mailbox_extension.dart';
import 'message.dart';
import 'process_settings.dart';
// import 'process_sync.dart';

/// Setting this to try will cause the isolate to dump lots
/// of output to stdout. This causes problems with the
/// some process on the primary isolate side, but often it is the
/// only way to debug the process in isolate code as the
/// debugger hangs.
const debugIsolate = false;

void startIsolate(IsolateChannel channel) {
  processLogger(() => 'starting isolate');
  unawaited(_startIsolate(channel));

  processLogger(() => 'waiting for isolate to spawn');
}

/// Starts an isolate that spawns the command.
Future<void> _startIsolate(IsolateChannel channel) {
  processLogger(() => 'getting sendable');
  final sendable = channel.asSendable();
  processLogger(() => 'calling spawn');
  return Isolate.spawn<IsolateChannelSendable>(
    _body,
    sendable,
    onError: sendable.errorPort,
    debugName:
        'ProcessInIsolate - ${channel.process.command} ${channel.process.args}',
  );
}

Future<void> _body(IsolateChannelSendable channel) async {
  isolateLogger(() => 'body entered');

  isolateLogger(() => green(
      '''process running: ${channel.process.command} ${channel.process.args}'''));

  /// We are now running in the isolate.
  isolateLogger(() => 'started');
  final mailboxToPrimaryIsolate = channel.toPrimaryIsolate.materialize();
  isolateLogger(() => 'mailboxes materialized');
  ReceivePort? port;

  try {
    final process = await _run(channel.process);

    isolateLogger(() => 'listen to recieve port');
    port = _handleStdin(process);

    /// used to wait for the stdout stream to finish streaming
    final stdoutStreamDone = Completer<void>();
    final stderrStreamDone = Completer<void>();

    late StreamSubscription<List<int>> stdoutSub;
    late StreamSubscription<List<int>> stderrSub;

    if (channel.process.hasStdio) {
      /// subscribe to data the process writes to stdout and send
      /// it back to the parent isolate
      stdoutSub = _sendStdoutToPrimary(
          process, mailboxToPrimaryIsolate, stdoutStreamDone);

      isolateLogger(() => 'listen of stdout completed');

      /// subscribe to data the process writes to stderr and send
      /// it back to the parent isolate
      stderrSub = _sendStderrToPrimary(
          process, mailboxToPrimaryIsolate, stderrStreamDone);

      isolateLogger(() => 'waiting in isolate for process to exit');
    }

    var exitCode = 0;
    if (!channel.process.detached) {
      /// wait for the process to exit and all stream
      /// finish being written to.
      exitCode = await process.exitCode;
      isolateLogger(() => 'process has exited with exitCode: $exitCode');
    } else {
      /// as we are detached we can't get an exit code so we
      /// send a bogus 0 - all good - exit code.
      /// Not certain if this is the right action but
      /// the primary isolate will wait for ever unless we send this.
      /// The primary isolate does know its a detached process
      /// so it can still do something 'interesting'.
      isolateLogger(
          () => "We run a detached process so we can't get the exit code");
    }

    if (channel.process.hasStdio) {
      await Future.wait<void>(
          [stdoutStreamDone.future, stderrStreamDone.future]);

      isolateLogger(() => 'streams are done - sending exit code');
    }

    await mailboxToPrimaryIsolate.postMessage(Message.exit(exitCode));

    if (channel.process.hasStdio) {
      await stdoutSub.cancel();
      await stderrSub.cancel();
    }
  } on RunException catch (e, _) {
    isolateLogger(() => 'Exception caught: $e');
    await mailboxToPrimaryIsolate.postMessage(Message.runException(e));
  }
  // ignore: avoid_catches_without_on_clauses
  catch (e, st) {
    await mailboxToPrimaryIsolate.postMessage(Message.runException(
        RunException.fromException(
            e, channel.process.command, channel.process.args,
            stackTrace: Trace.from(st))));
  }

  /// If _run throws then this port won't have been initialised.
  port?.close();
  isolateLogger(() => 'Isolate is exiting');
}

Future<Process> _run(ProcessSettings processSettings) async {
  final runner = ProcessRunner(processSettings);
  isolateLogger(() => 'starting process ${processSettings.command} in isolate');

  /// Start the process
  await runner.start();

  final process = runner.process!;

  isolateLogger(() =>
      'process launched ${processSettings.command} ${processSettings.args}');
  return process;
}

// TODO(bsutton): I don't think this is actually being used.
// As the isolate runs in the same process it still has
// direct access to stdin so we don't need to pass stdin
// across the isolate barrier.
// The only question is if we have scnenarios where we want
// to artifically send stdin across this maybe in a piping
// scenario?
ReceivePort _handleStdin(Process process) => ReceivePort()
  ..listen((message) async {
    isolateLogger(() => ' recieved message');
    if (message is List<int> || message is String) {
      // We received bytes from the primary isolate to write into stdin.
      if (message is String) {
        message = utf8.encode(message);
      }
      process.stdin.add(message as List<int>);
      await process.stdin.flush();

      // /// The tell the sender that we got their data and
      // /// sent it to stdin
      // await mailboxToPrimaryIsolate.postMessage(Message.ack());
    } else {
      throw ProcessSyncException('Wrong message: $message');
    }
  });

/// Setup listeners for stderr to send the data back to the primary
/// isolate via a mailbox.
StreamSubscription<List<int>> _sendStderrToPrimary(Process process,
    Mailbox mailboxToPrimaryIsolate, Completer<void> stderrStreamDone) {
  late StreamSubscription<List<int>> stderrSub;

  // ignore: join_return_with_assignment
  stderrSub = process.stderr.listen((data) async {
    stderrSub.pause();
    isolateLogger(() => 'recieved from called processes stderr:$data');
    final message = Message.stderr(data as Uint8List);
    await mailboxToPrimaryIsolate.postMessage(message);
    stderrSub.resume();
  }, onDone: () {
    isolateLogger(() => 'marking stderr stream completed');
    stderrStreamDone.complete();
  });

  return stderrSub;
}

/// Setup listeners for stdout to send the data back to the primary
/// isolate via a mailbox.
StreamSubscription<List<int>> _sendStdoutToPrimary(Process process,
    Mailbox mailboxToPrimaryIsolate, Completer<void> stdoutStreamDone) {
  late StreamSubscription<List<int>> stdoutSub;

  // ignore: join_return_with_assignment
  stdoutSub = process.stdout.listen((data) async {
    stdoutSub.pause();
    isolateLogger(
        () => 'posting data to primaries stdout: ${utf8.decode(data)}');
    await mailboxToPrimaryIsolate
        .postMessage(Message.stdout(data as Uint8List));
    stdoutSub.resume();
  }, onDone: () {
    isolateLogger(() => 'marking stdout stream completed');
    stdoutStreamDone.complete();
  });
  return stdoutSub;
}

String? _isolateID;
void isolateLogger(String Function() message) {
  if (debugIsolate) {
    _isolateID ??= Service.getIsolateId(Isolate.current);
    print('isolate($_isolateID): ${message()}');
  }
}
