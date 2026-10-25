import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dcli/src/script/sdk_archive_extractor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('extracts files under dart-sdk', () {
    final temp = Directory.systemTemp.createTempSync('dcli-sdk-archive-');
    try {
      final zip = File(p.join(temp.path, 'sdk.zip'));
      final archive = Archive()
        ..add(ArchiveFile.string('dart-sdk/bin/dart', 'safe'));
      zip.writeAsBytesSync(ZipEncoder().encode(archive));
      extractDartSdkArchive(zip.path, p.join(temp.path, 'install'));
      expect(
        File(
          p.join(temp.path, 'install', 'dart-sdk', 'bin', 'dart'),
        ).readAsStringSync(),
        'safe',
      );
    } finally {
      temp.deleteSync(recursive: true);
    }
  });

  for (final name in [
    'dart-sdk/../../outside',
    'dart-sdk/..\\..\\outside',
    '/dart-sdk/bin/dart',
    'C:/dart-sdk/bin/dart',
  ]) {
    test('rejects unsafe archive entry $name before writing', () {
      final temp = Directory.systemTemp.createTempSync('dcli-sdk-archive-');
      try {
        final zip = File(p.join(temp.path, 'sdk.zip'));
        final archive = Archive()
          ..add(ArchiveFile.string('dart-sdk/bin/dart', 'safe'))
          ..add(ArchiveFile.string(name, 'unsafe'));
        zip.writeAsBytesSync(ZipEncoder().encode(archive));
        expect(
          () => extractDartSdkArchive(zip.path, p.join(temp.path, 'install')),
          throwsFormatException,
        );
        expect(Directory(p.join(temp.path, 'install')).existsSync(), isFalse);
      } finally {
        temp.deleteSync(recursive: true);
      }
    });
  }

  test('rejects a ZIP symlink before writing a preceding valid file', () {
    final temp = Directory.systemTemp.createTempSync('dcli-sdk-archive-');
    try {
      final zip = File(p.join(temp.path, 'sdk.zip'));
      final link = ArchiveFile.string('dart-sdk/link', '../outside')
        ..mode = 0xa1ff;
      final archive = Archive()
        ..add(ArchiveFile.string('dart-sdk/bin/dart', 'safe'))
        ..add(link);
      final bytes = ZipEncoder().encode(archive);
      // ZipEncoder marks archives as DOS-created. Mark the central directory
      // as Unix-created so ZipDecoder interprets the mode as a symlink.
      for (var i = 0; i < bytes.length - 6; i++) {
        if (bytes[i] == 0x50 &&
            bytes[i + 1] == 0x4b &&
            bytes[i + 2] == 0x01 &&
            bytes[i + 3] == 0x02) {
          bytes[i + 5] = 3;
        }
      }
      zip.writeAsBytesSync(bytes);
      expect(
        () => extractDartSdkArchive(zip.path, p.join(temp.path, 'install')),
        throwsFormatException,
      );
      expect(Directory(p.join(temp.path, 'install')).existsSync(), isFalse);
    } finally {
      temp.deleteSync(recursive: true);
    }
  });
}
