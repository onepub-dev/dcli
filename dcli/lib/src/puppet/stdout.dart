import 'dart:convert';
import 'dart:io';

class PuppetStdout implements Stdout {
  PuppetStdout(this.stdout);

  Stdout stdout;
  IOSink? _nonBlocking;

  /// Whether there is a terminal attached to stdout.
  @override
  bool get hasTerminal => stdout.hasTerminal;

  /// The number of columns of the terminal.
  ///
  /// If no terminal is attached to stdout, a [StdoutException] is thrown. See
  /// [hasTerminal] for more info.
  @override
  int get terminalColumns => stdout.terminalColumns;

  /// The number of lines of the terminal.
  ///
  /// If no terminal is attached to stdout, a [StdoutException] is thrown. See
  /// [hasTerminal] for more info.
  @override
  int get terminalLines => stdout.terminalLines;

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
  bool get supportsAnsiEscapes => stdout.supportsAnsiEscapes;

  /// A non-blocking `IOSink` for the same output.
  @override
  IOSink get nonBlocking => _nonBlocking ??= stdout.nonBlocking;

  @override
  Encoding get encoding => stdout.encoding;

  @override
  set encoding(Encoding encoding) {
    stdout.encoding = encoding;
  }

  @override
  void add(List<int> data) {
    stdout.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    stdout.addError(error, stackTrace);
  }

  @override
  // ignore: strict_raw_type
  Future addStream(Stream<List<int>> stream) => stdout.addStream(stream);

  @override
  // ignore: strict_raw_type
  Future close() => stdout.close();

  @override
  // ignore: strict_raw_type
  Future get done => stdout.done;

  @override
  // ignore: strict_raw_type
  Future flush() => stdout.flush();

  @override
  void write(Object? object) {
    stdout.write(object);
  }

  @override
  // ignore: strict_raw_type
  void writeAll(Iterable objects, [String sep = '']) {
    stdout.writeAll(objects, sep);
  }

  @override
  void writeCharCode(int charCode) {
    stdout.writeCharCode(charCode);
  }

  @override
  void writeln([Object? object = '']) {
    stdout.writeln(object);
  }
}
