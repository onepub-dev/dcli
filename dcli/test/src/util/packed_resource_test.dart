import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('unpack preserves bytes across write-buffer boundaries', () {
    final directory = Directory.systemTemp.createTempSync('dcli-unpack-');
    try {
      final bytes = List<int>.generate(128 * 1024 + 7, (index) => index % 256);
      final resource = _Resource(base64.encode(bytes));
      final output = p.join(directory.path, 'data.bin');
      resource.unpack(output);
      expect(File(output).readAsBytesSync(), bytes);
    } finally {
      directory.deleteSync(recursive: true);
    }
  });

  test(
    'unpack handles independent padded lines and an unterminated last line',
    () {
      final directory = Directory.systemTemp.createTempSync('dcli-unpack-');
      try {
        final contents =
            '\n${base64.encode([0, 255])}\r\n\n'
            '${base64.encode([42])}';
        final resource = _Resource(contents);
        final output = p.join(directory.path, 'nested', 'data.bin');
        resource.unpack(output);
        expect(File(output).readAsBytesSync(), [0, 255, 42]);
      } finally {
        directory.deleteSync(recursive: true);
      }
    },
  );
}

class _Resource extends PackedResource {
  const _Resource(this.content);

  @override
  final String content;

  @override
  String get checksum => '';

  @override
  String get originalPath => 'data.bin';
}
