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
  static const String msgExit = '0';
  static final int _msgExitCode = msgExit.codeUnitAt(0);
  // The process has written to stdout. The data
  // written is contained from the second byte
  static const String msgStdout = '1';
  static final int _msgStdoutCode = msgStdout.codeUnitAt(0);
  // The process has written to stderr. The data
  // written is contained from the second byte
  static const String msgStderr = '2';
  static final int _msgStderrCode = msgStderr.codeUnitAt(0);

  BytesBuilder builder = BytesBuilder();
  

  Uint8List get message => builder.takeBytes();
}

/// Handle messages sent back from the isolate.
class MessageResponse {
  MessageResponse.fromLine(this.line) {
    messageCode = line[0];
  }
  final String line;
  late final String messageCode;

  void onStdout(void Function(String line) action) {
    if (messageCode == Message.msgStdout) {
      action(line.substring(1));
    }
  }

  void onStderr(void Function(String line) action) {
    if (messageCode == Message.msgStderr) {
      action(line.substring(1));
    }
  }

  void onExit(void Function(int exitCode) action) {
    if (messageCode == Message.msgStderr) {
      action(line[1].codeUnitAt(0));
    }
  }
}
