// @dart=3.0

import 'package:dcli_core/dcli_core.dart';

import '../../util/runnable_process.dart';
import 'message.dart';

/// Handle messages sent back from the spawned isolate.
///
class MessageResponse {
  MessageResponse.fromData(List<int> data) {
    messageType = MessageType.values[data[0]];
    if (data.length > 1) {
      payload = data.sublist(1);
    } else {
      payload = [];
    }
    processLogger(() => 'Recieved Message $this');
  }
  late final List<int> payload;
  late final MessageType messageType;

  void onStdout(void Function(List<int> payload) action) {
    if (messageType == MessageType.stdout) {
      action(payload);
    }
  }

  void onStderr(void Function(List<int> payload) action) {
    if (messageType == MessageType.stderr) {
      action(payload);
    }
  }

  void onException(void Function(RunException exception) action) {
    if (messageType == MessageType.exception) {
      action(RunException.fromJsonString(String.fromCharCodes(payload)));
    }
  }

  void onExit(void Function(int exitCode) action) {
    if (messageType == MessageType.exitCode) {
      action(payload[0]);
    }
  }

  @override
  String toString() => '''
type: $messageType, payload: (len: ${payload.length}) ${(messageType == MessageType.exitCode) ? payload[0] : String.fromCharCodes(payload)}''';
}
