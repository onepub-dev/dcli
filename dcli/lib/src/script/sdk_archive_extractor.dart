import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

/// Extracts an SDK archive after checking every entry stays under dart-sdk.
void extractDartSdkArchive(String archivePath, String destination) {
  final archive = ZipDecoder().decodeBytes(File(archivePath).readAsBytesSync());
  final root = p.absolute(destination);

  // Validate the entire archive before creating any files. ZIP entry names use
  // forward slashes on every platform; backslashes can act as separators on
  // Windows and must not be accepted as literal filename characters here.
  for (final entry in archive) {
    final name = entry.name;
    final parts = name.split('/');
    if (name.isEmpty ||
        name.startsWith('/') ||
        name.contains('\\') ||
        name.contains(':') ||
        name.contains('\u0000') ||
        parts.first != 'dart-sdk' ||
        parts.any((part) => part == '..' || part == '.') ||
        (entry.isFile && parts.length < 2) ||
        entry.isSymbolicLink ||
        (entry.mode & 0xf000) == 0xa000) {
      throw const FormatException('Unsafe Dart SDK archive entry');
    }
    final output = p.normalize(p.join(root, name));
    if (output != root && !p.isWithin(root, output)) {
      throw const FormatException('Unsafe Dart SDK archive entry');
    }
  }

  for (final entry in archive) {
    final output = p.join(root, entry.name);
    if (entry.isFile) {
      final file = File(output);
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(entry.content as List<int>);
    } else {
      Directory(output).createSync(recursive: true);
    }
  }
}
