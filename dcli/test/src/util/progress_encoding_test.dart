import 'dart:convert';
import 'dart:typed_data';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/progress/progress_impl.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(RangeError)
void main() {
  test('Progress.capture decodes UTF-8 across chunk boundaries', () {
    final progress = Progress.capture();
    const text = '══╡ EXCEPTION\nSecond line\n';
    final bytes = utf8.encode(text);

    progress as ProgressImpl
      ..addToStdout(bytes.sublist(0, 1))
      ..addToStdout(bytes.sublist(1, 2))
      ..addToStdout(bytes.sublist(2))
      ..close();

    expect(progress.lines, equals(['══╡ EXCEPTION', 'Second line']));
  });

  test('Progress.capture decodes UTF-16LE across chunk boundaries', () {
    const utf16le = Utf16LeCodec();
    final progress = Progress.capture(encoding: utf16le);
    const text = 'Hello ══\nSecond line\n';
    final bytes = utf16le.encode(text);

    progress as ProgressImpl
      ..addToStdout(bytes.sublist(0, 1))
      ..addToStdout(bytes.sublist(1, 3))
      ..addToStdout(bytes.sublist(3))
      ..close();

    expect(progress.lines, equals(['Hello ══', 'Second line']));
  });
}

class Utf16LeCodec extends Encoding {
  const Utf16LeCodec();

  @override
  String get name => 'utf-16le';

  @override
  Converter<String, List<int>> get encoder => const Utf16LeEncoder();

  @override
  Converter<List<int>, String> get decoder => const Utf16LeDecoder();
}

class Utf16LeEncoder extends Converter<String, List<int>> {
  const Utf16LeEncoder();

  @override
  List<int> convert(String input) {
    final units = input.codeUnits;
    final output = Uint8List(units.length * 2);
    for (var i = 0; i < units.length; i++) {
      final unit = units[i];
      output[i * 2] = unit & 0xff;
      output[i * 2 + 1] = (unit >> 8) & 0xff;
    }
    return output;
  }

  @override
  ChunkedConversionSink<String> startChunkedConversion(Sink<List<int>> sink) =>
      _Utf16LeEncoderSink(sink);
}

class _Utf16LeEncoderSink implements ChunkedConversionSink<String> {
  final Sink<List<int>> _sink;

  _Utf16LeEncoderSink(this._sink);

  @override
  void add(String chunk) {
    _sink.add(const Utf16LeEncoder().convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}

class Utf16LeDecoder extends Converter<List<int>, String> {
  const Utf16LeDecoder();

  @override
  String convert(List<int> input) => _decode(input, null).$1;

  @override
  ChunkedConversionSink<List<int>> startChunkedConversion(Sink<String> sink) =>
      _Utf16LeDecoderSink(StringConversionSink.from(sink));

  static (String, int?) _decode(List<int> input, int? pending) {
    final bytes = <int>[
      if (pending != null) pending,
      ...input,
    ];
    final codeUnits = <int>[];
    var i = 0;
    for (; i + 1 < bytes.length; i += 2) {
      codeUnits.add(bytes[i] | (bytes[i + 1] << 8));
    }
    final remainder = i < bytes.length ? bytes[i] : null;
    return (String.fromCharCodes(codeUnits), remainder);
  }
}

class _Utf16LeDecoderSink implements ChunkedConversionSink<List<int>> {
  final StringConversionSink _sink;

  int? _pending;

  _Utf16LeDecoderSink(this._sink);

  @override
  void add(List<int> chunk) {
    final result = Utf16LeDecoder._decode(chunk, _pending);
    _pending = result.$2;
    if (result.$1.isNotEmpty) {
      _sink.add(result.$1);
    }
  }

  @override
  void close() {
    if (_pending != null) {
      _sink.add('\uFFFD');
      _pending = null;
    }
    _sink.close();
  }
}
