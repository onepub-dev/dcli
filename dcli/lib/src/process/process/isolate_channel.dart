import 'dart:isolate';

import 'package:native_synchronization/mailbox.dart';
import 'package:native_synchronization/sendable.dart';

import 'process_settings.dart';

/// A set of elelements for communication between the main isolate
///  and the secondary isolate.
class IsolateChannel {
  IsolateChannel({
    required this.process,
  });

  /// Settings used when launching the process in the secondary isolate.
  ProcessSettings process;

  /// Back channel so the secondary isolate can send data to the
  /// primary isolate.
  Mailbox toPrimaryIsolate = Mailbox();

  /// Report any isolate errors back to the primary isolate.
  ReceivePort errorPort = ReceivePort();
  ReceivePort exitPort = ReceivePort();

  IsolateChannelSendable asSendable() => IsolateChannelSendable(
      process: process,
      toPrimaryIsolate: toPrimaryIsolate.asSendable,
      errorPort: errorPort.sendPort,
      exitPort: exitPort.sendPort);
}

class IsolateChannelSendable {
  IsolateChannelSendable({
    required this.process,
    required this.toPrimaryIsolate,
    required this.errorPort,
    required this.exitPort,
  });
  ProcessSettings process;
  Sendable<Mailbox> toPrimaryIsolate;
  SendPort errorPort;
  SendPort exitPort;
}
