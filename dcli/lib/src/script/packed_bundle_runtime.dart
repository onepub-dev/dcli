/// Runtime embedded in packed launchers; only Dart SDK imports are needed.
const packedBundleRuntime = r'''
Future<String> prepareExecutable() async {
  final root = Directory(_cacheRoot())..createSync(recursive: true);
  _chmod(root.path, 0x1c0);
  final cache = Directory(_join(root.path, bundleKey));
  final lock = File(_join(root.path, '$bundleKey.lock'))
      .openSync(mode: FileMode.append);
  lock.lockSync(FileLock.blockingExclusive);
  try {
    // With the per-key lock held, these can only be abandoned extractions.
    for (final entry in root.listSync(followLinks: false)) {
      if (entry is Directory &&
          entry.uri.pathSegments.where((part) => part.isNotEmpty).last
              .startsWith('.$bundleKey-')) {
        entry.deleteSync(recursive: true);
      }
    }
    if (!_complete(cache)) {
      final timer = Stopwatch()..start();
      final staging = root.createTempSync('.$bundleKey-');
      _chmod(staging.path, 0x1c0);
      try {
        // Decode one independently compressed 256 KiB part at a time.
        for (final item in ResourceRegistry.resources.entries) {
          final metadata = manifest[item.key] as Map<String, dynamic>;
          final destination = File(_join(staging.path, item.key));
          item.value.unpack(destination.path);
          if (destination.lengthSync() != metadata['length'] ||
              _fileCrc(destination) != metadata['crc32']) {
            throw StateError('Extracted resource failed verification: ${item.key}');
          }
          final mode = metadata['mode'] as int;
          _chmod(destination.path, 0x180 | (mode & 0x40));
        }
        File(_join(staging.path, '.complete')).writeAsStringSync(bundleKey,
            flush: true);
        if (cache.existsSync()) cache.deleteSync(recursive: true);
        staging.renameSync(cache.path);
      } finally {
        if (staging.existsSync()) staging.deleteSync(recursive: true);
      }
      _log('Extracted bundle to ${cache.path} in ${timer.elapsedMilliseconds} ms');
    } else {
      _log('Using cached bundle: ${cache.path}');
    }
  } finally {
    lock.unlockSync();
    lock.closeSync();
  }
  return _join(cache.path, 'bin', entrypoint);
}

bool _complete(Directory cache) {
  final marker = File(_join(cache.path, '.complete'));
  if (!marker.existsSync() || marker.readAsStringSync() != bundleKey) return false;
  for (final item in manifest.entries) {
    final file = File(_join(cache.path, item.key));
    final metadata = item.value as Map<String, dynamic>;
    if (!file.existsSync() || file.lengthSync() != metadata['length'] ||
        _fileCrc(file) != metadata['crc32']) return false;
  }
  return true;
}

String _cacheRoot() {
  final env = Platform.environment;
  final override = env['DCLI_BUNDLE_CACHE'];
  if (override != null && override.isNotEmpty) return Directory(override).absolute.path;
  final home = Platform.isWindows
      ? env['USERPROFILE'] ?? env['HOME']
      : env['HOME'];
  if (home == null || home.isEmpty) {
    throw StateError('Unable to determine the user home directory');
  }
  return _join(home, '.dcli', 'cache', 'bundles');
}

void _log(String message) {
  if (Platform.environment['DCLI_BUNDLE_VERBOSE'] == '1') stderr.writeln(message);
}

void _chmod(String path, int mode) {
  if (Platform.isWindows) return;
  final libc = DynamicLibrary.process();
  final malloc = libc.lookupFunction<Pointer<Void> Function(Size),
      Pointer<Void> Function(int)>('malloc');
  final free = libc.lookupFunction<Void Function(Pointer<Void>),
      void Function(Pointer<Void>)>('free');
  final chmod = libc.lookupFunction<Int32 Function(Pointer<Uint8>, Uint32),
      int Function(Pointer<Uint8>, int)>('chmod');
  final bytes = utf8.encode(path);
  final pointer = malloc(bytes.length + 1).cast<Uint8>();
  if (pointer == nullptr) throw StateError('Unable to allocate path');
  try {
    pointer.asTypedList(bytes.length + 1)..setAll(0, bytes)..[bytes.length] = 0;
    if (chmod(pointer, mode) != 0) throw FileSystemException('chmod failed', path);
  } finally {
    free(pointer.cast<Void>());
  }
}

String _join(String first, String second, [String? third, String? fourth, String? fifth]) =>
    [first, second, if (third != null) third, if (fourth != null) fourth, if (fifth != null) fifth]
        .join(Platform.pathSeparator);

final _crcTable = List<int>.generate(256, (value) {
  var crc = value;
  for (var bit = 0; bit < 8; bit++) {
    crc = (crc & 1) == 1 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
  }
  return crc;
});

int _fileCrc(File file) {
  final input = file.openSync();
  var crc = 0xffffffff;
  try {
    while (true) {
      final bytes = input.readSync(64 * 1024);
      if (bytes.isEmpty) break;
      for (final byte in bytes) {
        crc = _crcTable[(crc ^ byte) & 0xff] ^ (crc >> 8);
      }
    }
    return crc ^ 0xffffffff;
  } finally {
    input.closeSync();
  }
}
''';

/// Standalone decoding interface for the generated resource classes.
const packedResourceRuntime = '''
import 'dart:convert';
import 'dart:io';

abstract class PackedResourcePart {
  const PackedResourcePart();
  String get content;
  int get length;
}

abstract class PackedResource {
  const PackedResource();
  String get originalPath;
  String get checksum;
  Iterable<PackedResourcePart> get parts;

  void unpack(String path) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    final output = file.openSync(mode: FileMode.write);
    try {
      for (final part in parts) {
        final bytes = gzip.decode(base64.decode(part.content));
        if (bytes.length != part.length) {
          throw FormatException('Packed resource part has an invalid length');
        }
        output.writeFromSync(bytes);
      }
    } finally {
      output.flushSync();
      output.closeSync();
    }
  }
}
''';
