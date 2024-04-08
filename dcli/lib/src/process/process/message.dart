// @dart=3.0

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import '../../../dcli.dart';

enum MessageType {
  /// pass the isolates send port
  sendPort,

  /// the processes exit code
  exitCode,

  /// An acknowledgement that we recieved a message.
  ack,

  /// data which the process wrote to stdout.
  stdout,

  /// data which the process wrote to stderr
  stderr,

  /// data that the primary isolate received from
  /// stdin
  stdin,

  /// An exception thrown by the isolate.
  exception
}

/// Used to send data back from the isolate over the
/// recieve channel. The first byte is used to
/// indicate the type of message.
class Message {
  /// Used to send the native send port back to the
  /// spawner, so they can send us data.
  /// Spawnee -> Spawner
  Message.port(SendPort sendPort) {
    final port = Int64List(1)..[0] = sendPort.nativePort;

    builder
      ..addByte(MessageType.sendPort.index)
      ..add(port.buffer.asUint8List());
  }

  /// Send data to the isolate that came from
  /// the primary isolates stdin.
  Message.stdin(Uint8List data) {
    builder
      ..addByte(MessageType.stdin.index)
      ..add(data);
  }

  /// Send data that the process wrote to stdout
  /// back to the spawner.
  /// Spawnee -> Spawner
  Message.stdout(Uint8List data) {
    builder
      ..addByte(MessageType.stdout.index)
      ..add(data);
  }

  /// Send data that the process wrote to stderr
  /// back to the spawner.
  /// Spawnee -> Spawner
  Message.stderr(Uint8List data) {
    builder
      ..addByte(MessageType.stderr.index)
      ..add(data);
  }

  /// When the process exists send the exitCode
  /// back to the spawener.
  /// Spawnee -> Spawner
  Message.exit(int exitCode) {
    builder
      ..addByte(MessageType.exitCode.index)
      ..addByte(exitCode);
  }

  /// Used to acknowlede that a message has been recieved.
  Message.ack() {
    builder.addByte(MessageType.ack.index);
  }

  /// Allows us to pass a RunException to the primary isolate.
  Message.runException(RunException e) {
    final data = e.toJsonString();
    builder
      ..addByte(MessageType.exception.index)
      ..add(data.codeUnits);
  }

  BytesBuilder builder = BytesBuilder();

  Uint8List? _content;

  Uint8List get content => _content ??= builder.takeBytes();

  MessageType get type => MessageType.values[content[0]];

  List<int> get payload => content.sublist(1);

  @override
  String toString() => 'length: ${builder.length}';
}
