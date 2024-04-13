// ignore_for_file: unreachable_from_main

import 'dart:async';
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/process/process/message.dart';
import 'package:dcli/src/process/process/message_response.dart';
import 'package:dcli/src/process/process/process_in_isolate2.dart';
import 'package:dcli/src/process/process/process_settings.dart';
import 'package:native_synchronization/mailbox.dart';
import 'package:native_synchronization/sendable.dart';

void main() {
  print('starting');
  firstline();
  print('finished');
}

void firstline() {
  'getent passwd bsutton'.firstLine!.split(':');
}

void test6() {
  DartSdk().runPubGet('.', progress: Progress.devNull());
}

/// test interaction between spawned app and the console
void test5() {
  'dcli_unit_tester --ask'.start(terminal: true);
  print('do something after');
}

void test4() {
  final mailboxToPrimaryIsolate = Mailbox();
  final mailboxFromPrimaryIsolate = Mailbox();

  startIsolate2(ProcessSettings('which', args: ['which']),
      mailboxFromPrimaryIsolate, mailboxToPrimaryIsolate);

  MessageResponse response;
  do {
    response = MessageResponse.fromData(mailboxToPrimaryIsolate.take())
      ..onStdout((data) {
        print(green('primary:  ${String.fromCharCodes(data)}'));
      })
      ..onStderr((data) {
        printerr(red('primary: ${String.fromCharCodes(data)}'));
      });
  } while (response.messageType != MessageType.exitCode);
  print(orange('primary: received exit message'));
}

void _run(String arg) {
  print('Hello from isolate: $arg');
}

void test1() {
  unawaited(Isolate.spawn(_run, 'hellow'));
  io.sleep(const Duration(seconds: 10));
}

void test2() {
  final mailbox = Mailbox();
  unawaited(Isolate.spawn(_run, 'hellow'));
  mailbox.take();
}

void test3() {
  final mailbox = Mailbox();
  unawaited(Isolate.spawn(_put, mailbox.asSendable));
  final response = mailbox.take();

  print('response ${String.fromCharCodes(response)}');
}

void _put(Sendable<Mailbox> mailbox) {
  print('isolate running');
  mailbox.materialize().put(Uint8List.fromList('Hello back to you'.codeUnits));
}
