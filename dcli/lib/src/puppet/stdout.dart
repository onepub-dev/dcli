import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'block_queue.dart';

class PuppetStdout implements Stdout {
  PuppetStdout(
      {this.hasTerminal = true,
      this.terminalColumns = 80,
      this.terminalLines = 24,
      this.supportsAnsiEscapes = true,
      Encoding encoding = utf8}) {
    _stream = controller.stream;
    _sink = IOSink(controller.sink, encoding: encoding);

    _blockQueue = BlockQueue(_stream);
  }

  StreamController<List<int>> controller = StreamController();
  late final IOSink _sink;
  late final Stream<List<int>> _stream;
  late final BlockQueue _blockQueue;

  IOSink? _nonBlocking;

  /// Whether there is a terminal attached to stdout.
  @override
  bool hasTerminal;

  /// The number of columns of the terminal.
  ///
  /// If no terminal is attached to stdout, a [StdoutException] is thrown. See
  /// [hasTerminal] for more info.
  @override
  int terminalColumns;

  /// The number of lines of the terminal.
  ///
  /// If no terminal is attached to stdout, a [StdoutException] is thrown. See
  /// [hasTerminal] for more info.
  @override
  int terminalLines;

  /// Whether connected to a terminal that supports ANSI escape sequences.
  ///
  /// Not all terminals are recognized, and not all recognized terminals can
  /// report whether they support ANSI escape sequences, so this value is a
  /// best-effort attempt at detecting the support.
  ///
  /// The actual escape sequence support may differ between terminals,
  /// with some terminals supporting more escape sequences than others,
  /// and some terminals even differing in behavior for the same escape
  /// sequence.
  ///
  /// The ANSI color selection is generally supported.
  ///
  /// Currently, a `TERM` environment variable containing the string `xterm`
  /// will be taken as evidence that ANSI escape sequences are supported.
  /// On Windows, only versions of Windows 10 after v.1511
  /// ("TH2", OS build 10586) will be detected as supporting the output of
  /// ANSI escape sequences, and only versions after v.1607 ("Anniversary
  /// Update", OS build 14393) will be detected as supporting the input of
  /// ANSI escape sequences.
  @override
  bool supportsAnsiEscapes;

  /// A non-blocking `IOSink` for the same output.
  @override
  IOSink get nonBlocking => _nonBlocking ??= stdout.nonBlocking;

  @override
  Encoding get encoding => _sink.encoding;

  @override
  set encoding(Encoding encoding) {
    _sink.encoding = encoding;
  }

  /// TODO: I'm uncertain what the default values should be here
  /// when calling _blockQueue.readLineSync as they are
  /// taken from the requirements of stdio.
  String? readLineSync() => _blockQueue.readLineSync(
      stdioType: StdioType.terminal,
      encoding: encoding,
      retainNewlines: true,
      lineMode: true);
  @override
  void write(Object? object) {
    _sink.write(object);
  }

  @override
  void writeln([Object? object = '']) {
    _sink.writeln(object);
  }

  @override
  void writeAll(covariant Iterable<Object> objects, [String sep = '']) {
    _sink.writeAll(objects, sep);
  }

  @override
  void add(List<int> data) {
    _sink.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _sink.addError(error, stackTrace);
  }

  @override
  void writeCharCode(int charCode) {
    _sink.writeCharCode(charCode);
  }

  @override
  // ignore: strict_raw_type
  Future addStream(Stream<List<int>> stream) => _sink.addStream(stream);
  @override
  // ignore: strict_raw_type
  Future flush() => _sink.flush();
  @override
  // ignore: strict_raw_type
  Future close() => _sink.close();
  @override
  // ignore: strict_raw_type
  Future get done => _sink.done;
}
