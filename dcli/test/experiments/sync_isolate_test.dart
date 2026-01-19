// for later use
// ignore_for_file: unreachable_from_main

import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/process/process/isolate_channel.dart';
import 'package:dcli/src/process/process/message.dart';
import 'package:dcli/src/process/process/message_response.dart';
import 'package:dcli/src/process/process/process_in_isolate.dart';
import 'package:dcli/src/process/process/process_settings.dart';
import 'package:dcli/src/util/isolate_id.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:native_synchronization_temp/native_synchronization.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(DeleteDirException)
/// @Throwing(MailBoxClosedException)
/// @Throwing(TouchException)
void main() {
  final runExperiments = env['DCLI_RUN_EXPERIMENTS'] == 'true';

  test('isolate test', firstline, skip: !runExperiments);

  test(
    'pub get',
    () {
      DartSdk().runPubGet('.', progress: Progress.devNull());
    },
    skip: !runExperiments,
  );

  /// test interaction between spawned app and the console
  test(
    'unit_tester',
    () {
      'dcli_unit_tester --ask'.start(terminal: true);
    },
    skip: !runExperiments || env['DCLI_RUN_INTERACTIVE_TESTS'] != 'true',
  );

  test(
    'test file system',
    () async {
      await TestFileSystem().withinZone((fs) async {
        await DartProject.self.warmup();
      });
    },
    skip: !runExperiments,
  );

  test(
    'spawn',
    () async {
      const lockName = 'spawn_test';
      await withTempDirAsync((lockPath) async {
        final isolate = isolateID;
        touch(join(lockPath, '.$pid.$isolate.$lockName'), create: true);

        // await NamedLock(name: lockName).withLockAsync(() async {
        _spawn(1);
        _spawn(2);
        _spawn(3);
      });
    },
    skip: !runExperiments,
  );
  // });
}

/// @Throwing(MailBoxClosedException)
void _spawn(int index) {
  // await NamedLock(name: lockName).withLockAsync(() async {
  final isolateChannel = IsolateChannel(
    process: ProcessSettings('dcli_unit_tester',
        args: ['-n', '-l', '5', '-o', '$index']),
  );

  startIsolate(isolateChannel);

  MessageResponse response;
  do {
    response = MessageResponse.fromData(isolateChannel.toPrimaryIsolate.take())
      ..onStdout((data) {
        print(green('primary:  ${String.fromCharCodes(data)}'));
      })
      ..onStderr((data) {
        printerr(red('primary: ${String.fromCharCodes(data)}'));
      });
  } while (response.messageType != MessageType.exitCode);
  print(orange('primary: received exit message'));
}

void firstline() {
  'getent passwd bsutton'.firstLine!.split(':');
}

void _run(String arg) {
  print('Hello from isolate: $arg');
}

void test1() {
  unawaited(Isolate.spawn(_run, 'hellow'));
  io.sleep(const Duration(seconds: 10));
}

/// @Throwing(MailBoxClosedException)
void test2() {
  final mailbox = Mailbox();
  unawaited(Isolate.spawn(_run, 'hellow'));
  mailbox.take();
}

/// @Throwing(MailBoxClosedException)
void test3() {
  final mailbox = Mailbox();
  unawaited(Isolate.spawn(_put, mailbox.asSendable));
  final response = mailbox.take();

  print('response ${String.fromCharCodes(response)}');
}

/// @Throwing(MailBoxClosedException)
/// @Throwing(MailBoxFullException)
void _put(Sendable<Mailbox> mailbox) {
  print('isolate running');
  mailbox.materialize().put(Uint8List.fromList('Hello back to you'.codeUnits));
}
