// @dart=3.0

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'process_channel.dart';

/// Used to send data back from the isolate over the
/// recieve channel. The first byte is used to
/// indicate the type of message.
class Message {
  /// Used to send the native send port back to the
  /// spawner, so they can send us data.
  /// Spawnee -> Spawner
  Message.port(SendPort sendPort) {
    final port = Int64List(1)..[0] = sendPort.nativePort;

    builder.add(port.buffer.asUint8List());
  }

  /// Send data that the process wrote to stdout
  /// back to the spawner.
  /// Spawnee -> Spawner
  Message.stdout(Uint8List data) {
    builder
      ..addByte(_msgStdoutCode)
      ..add(data);
  }

  /// Send data that the process wrote to stderr
  /// back to the spawner.
  /// Spawnee -> Spawner
  Message.stderr(Uint8List data) {
    builder
      ..addByte(_msgStderrCode)
      ..add(data);
  }

  /// When the process exists send the exitCode
  /// back to the spawener.
  /// Spawnee -> Spawner
  Message.exit(int exitCode) {
    builder
      ..addByte(_msgExitCode)
      ..addByte(exitCode);
  }

  /// Used by the spawner to acknowledge
  /// that it recieved a message.
  /// Spawner -> spawnee
  Message.received() {
    builder.add(Uint8List.fromList([ProcessChannel.RECEIVED]));
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

  Uint8List get content => builder.takeBytes();
}

/// Handle messages sent back from the spawned isolate.
/// 
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
      // print('processing exitCode');
      action(data[1]);
    }
  }
}
