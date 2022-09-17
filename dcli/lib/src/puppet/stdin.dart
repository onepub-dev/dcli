import 'dart:async';
import 'dart:convert';
import 'dart:io';

class PuppetStdin extends Stream<List<int>> implements Stdin {
  PuppetStdin(
      {this.echoMode = true,
      this.echoNewlineMode = true,
      this.lineMode = true});

  StreamController<List<int>> controller = StreamController();
  @override
  bool echoMode;

  @override
  bool echoNewlineMode;

  @override
  bool lineMode;

  @override
  bool get hasTerminal => stdin.hasTerminal;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    throw UnimplementedError();
  }

  @override
  int readByteSync() => stdin.readByteSync();

  @override
  String? readLineSync(
          {Encoding encoding = systemEncoding, bool retainNewlines = false}) =>
      stdin.readLineSync(encoding: encoding, retainNewlines: retainNewlines);

  @override
  bool get supportsAnsiEscapes => stdin.supportsAnsiEscapes;
}
