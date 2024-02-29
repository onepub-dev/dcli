// @dart=3.0

import 'dart:io';
import 'dart:typed_data';

/// Used to send data back from the isolate over the
/// recieve channel. The first byte is used to
/// indicate the type of message.
class Message {
  Message.stdout(Uint8List data) {
    builder
      ..addByte(_msgStdoutCode)
      ..add(data);
  }

  Message.stderr(Uint8List data) {
    builder
      ..addByte(_msgStderrCode)
      ..add(data);
  }

  Message.exit(int exitCode) {
    builder
      ..addByte(_msgExitCode)
      ..addByte(exitCode);
  }
  // The process has exited. The second byte will contain
  // the exit code.
  static const int msgExit = 0;
  static const int _msgExitCode = msgExit;
  // The process has written to stdout. The data
  // written is contained from the second byte
  static const int msgStdout = 1;
  static const int _msgStdoutCode = msgStdout;
  // The process has written to stderr. The data
  // written is contained from the second byte
  static const int msgStderr = 2;
  static const int _msgStderrCode = msgStderr;

  BytesBuilder builder = BytesBuilder();

  Uint8List get message => builder.takeBytes();
}

/// Handle messages sent back from the isolate.
class MessageResponse {
  MessageResponse.fromData(this.data) {
    messageCode = data[0];
  }
  final List<int> data;
  late final int messageCode;

  void onStdout(void Function(List<int> data) action) {
    if (messageCode == Message.msgStdout) {
      action(data.sublist(1));
    }
  }

  void onStderr(void Function(List<int> data) action) {
    if (messageCode == Message.msgStderr) {
      action(data.sublist(1));
    }
  }

  void onExit(void Function(int exitCode) action) {
    if (messageCode == Message.msgExit) {
      print('processing exitCode');
      action(data[1]);
    }
  }
}
