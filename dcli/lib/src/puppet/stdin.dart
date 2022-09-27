import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'block_queue.dart';

class PuppetStdin extends Stream<List<int>> implements Stdin {
  PuppetStdin(
      {this.echoMode = true,
      this.echoNewlineMode = true,
      this.lineMode = true,
      this.stdioType = StdioType.terminal}) {
    _blockQueue = BlockQueue(controller.stream);
    _sink = controller.sink;
  }

  static const _cr = 13;
  static const _lf = 10;

  StreamController<List<int>> controller = StreamController();
  late final StreamSink<List<int>> _sink;

  late final BlockQueue _blockQueue;

  @override
  bool echoMode;

  @override
  bool echoNewlineMode;

  @override
  bool lineMode;

  StdioType stdioType;

  @override
  bool get hasTerminal => stdin.hasTerminal;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    throw UnimplementedError();
  }

  void writeLineSync(String line) {
    final terminator = _crIsRequired ? [_cr, _lf] : [_lf];

    _sink
      ..add(utf8.encode(line))
      ..add(terminator);
  }

  void close() {
    _blockQueue.close();
  }

  @override
  int readByteSync() => _blockQueue.readByteSync();

  @override
  String? readLineSync(
          {Encoding encoding = systemEncoding, bool retainNewlines = false}) =>
      _blockQueue.readLineSync(
          stdioType: stdioType,
          encoding: encoding,
          retainNewlines: retainNewlines,
          lineMode: lineMode);

  // On Windows, if lineMode is disabled, only CR is received.
  bool get _crIsRequired =>
      Platform.isWindows && (stdioType == StdioType.terminal) && !lineMode;

  @override
  bool get supportsAnsiEscapes => stdin.supportsAnsiEscapes;
}
