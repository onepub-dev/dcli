// @dart=3.0

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'mailbox.dart';

class _CallbackSink implements Sink<String> {
  final void Function(String line) cb;

  _CallbackSink(this.cb);

  @override
  void add(String data) {
    cb(data);
  }

  @override
  void close() {}
}

final class _DartApiEntry extends Struct {
  external Pointer<Utf8> name;
  external Pointer<Void> function;
}

final class _DartApi extends Struct {
  @Int()
  external int major;

  @Int()
  external int minor;

  external Pointer<_DartApiEntry> functions;
}

class SyncProcess {
  final Mailbox _stdin = Mailbox();
  final Mailbox _stdout = Mailbox();

  late final SendPort _sendPort = _connectSendPort();

  late final splitter =
      const LineSplitter().startChunkedConversion(_CallbackSink(lines.add));
  late final decoder = const Utf8Decoder().startChunkedConversion(splitter);
  final List<String> lines = <String>[];

  SyncProcess();

  void writeAndFlush(String data) {
    _sendPort.send(data);
    final response = _stdin.takeOne();
    if (response.length != 0) {
      throw 'Something wrong: got ${response}';
    }
  }

  String readLine() {
    while (true) {
      if (lines.isNotEmpty) {
        return lines.removeAt(0);
      }

      _drainStdout();
    }
  }

  SendPort _connectSendPort() {
    final msg = _stdin.takeOne();
    if (msg.length != 8) {
      throw 'Wrong message: $msg';
    }
    final portId = msg.buffer.asInt64List()[0];

    final functions =
        NativeApi.initializeApiDLData.cast<_DartApi>().ref.functions;

    late Object Function(int) connectToPort;
    for (int i = 0; functions[i].name != nullptr; i++) {
      if (functions[i].name.toDartString() == 'Dart_NewSendPort') {
        connectToPort = functions[i]
            .function
            .cast<NativeFunction<Handle Function(Int64)>>()
            .asFunction();
        break;
      }
    }

    return connectToPort(portId) as SendPort;
  }

  void _drainStdout() {
    final bytes = _stdout.takeOne();
    decoder.add(bytes);
    _sendPort.send(0);
  }
}

SyncProcess runInteratively(String executable, List<String> arguments) {
  final process = SyncProcess();

  Isolate.spawn((mailboxAddrs) async {
    final stdinMailbox = Mailbox.fromAddress(mailboxAddrs[0]);
    final stdoutMailbox = Mailbox.fromAddress(mailboxAddrs[1]);

    final process = await Process.start(executable, arguments);

    late StreamSubscription<List<int>> stdoutSub;

    final port = ReceivePort()
      ..listen((message) async {
        if (message == 0) {
          stdoutSub.resume();
        } else if (message is List<int> || message is String) {
          // We are asked to write bytes into stdin.
          if (message is String) {
            message = utf8.encode(message);
          }
          process.stdin.add(message as List<int>);
          await process.stdin.flush();
          stdinMailbox.respond(null);
        } else {
          throw 'Wrong message: $message';
        }
      });

    final msg = Int64List(1)..[0] = port.sendPort.nativePort;
    stdinMailbox.respond(msg.buffer.asUint8List());

    stdoutSub = process.stdout.listen((data) {
      stdoutSub.pause();
      stdoutMailbox.respond(data as Uint8List);
    });
  }, [
    process._stdin.rawAddress,
    process._stdout.rawAddress,
  ]);

  return process;
}

void main() {
  final p = runInteratively('cat', []);

  for (var i = 0; i < 10; i++) {
    p.writeAndFlush('line $i\n');
    final line = p.readLine();
    print('from cat: $line');
  }
}
