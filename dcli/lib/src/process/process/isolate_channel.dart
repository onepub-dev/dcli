import 'dart:isolate';


import 'package:native_synchronization_temp/native_synchronization.dart';

import 'process_settings.dart';

/// A set of elelements for communication between the main isolate
///  and the secondary isolate.
class IsolateChannel {
  /// Settings used when launching the process in the secondary isolate.
  ProcessSettings process;

  /// Back channel so the secondary isolate can send data to the
  /// primary isolate.
  var toPrimaryIsolate = Mailbox();

  /// Report any isolate errors back to the primary isolate.
  var errorPort = ReceivePort();

  var exitPort = ReceivePort();

  IsolateChannel({
    required this.process,
  });

  void close() {
    errorPort.close();
    exitPort.close();
    toPrimaryIsolate.close();
  }

  IsolateChannelSendable asSendable() => IsolateChannelSendable(
      process: process,
      toPrimaryIsolate: toPrimaryIsolate.asSendable,
      errorPort: errorPort.sendPort,
      exitPort: exitPort.sendPort);
}

class IsolateChannelSendable {
  ProcessSettings process;

  Sendable<Mailbox> toPrimaryIsolate;

  SendPort errorPort;

  SendPort exitPort;

  IsolateChannelSendable({
    required this.process,
    required this.toPrimaryIsolate,
    required this.errorPort,
    required this.exitPort,
  });
}
