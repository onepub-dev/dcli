import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../resources/resource_packer.dart';
import 'native_launcher.dart';
import 'packed_bundle_runtime.dart';

/// Generates a self-contained launcher and compressed classes for a CLI bundle.
class PackedBundleBuilder {
  /// Writes sources into an empty directory and returns the entrypoint.
  static String generate(String bundle, String destination, String executable) {
    final root = Directory(destination)..createSync(recursive: true);
    final manifest = <String, Map<String, Object>>{};
    final files = Directory(
      bundle,
    ).listSync(recursive: true, followLinks: false);
    if (files.any((entry) => entry is Link)) {
      throw ArgumentError('Packed bundles cannot contain symbolic links.');
    }
    final assets = <(String, String)>[];
    for (final file
        in files.whereType<File>().toList()
          ..sort((a, b) => a.path.compareTo(b.path))) {
      final relative = p.posix.joinAll(
        p.split(p.relative(file.path, from: bundle)),
      );
      if (relative == '.complete') {
        throw ArgumentError('The bundle filename .complete is reserved.');
      }
      final reader = file.openSync();
      final hashOutput = AccumulatorSink<Digest>();
      final hash = sha256.startChunkedConversion(hashOutput);
      var crc = 0;
      try {
        while (true) {
          final bytes = reader.readSync(64 * 1024);
          if (bytes.isEmpty) {
            break;
          }
          crc = getCrc32(bytes, crc);
          hash.add(bytes);
        }
        hash.close();
      } finally {
        reader.closeSync();
      }
      final checksum = hashOutput.events.single.toString();
      final stat = file.statSync();
      manifest[relative] = {
        'length': stat.size,
        'mode': stat.mode & 0x1ff,
        'sha256': checksum,
        'crc32': crc,
      };
      final className = 'Resource${assets.length}';
      ResourcePacker.packFile(
        source: file.path,
        destination: p.join(root.path, '$className.g.dart'),
        className: className,
        originalPath: relative,
        checksum: checksum,
        runtimeImport: 'packed_resource.dart',
      );
      assets.add((relative, className));
    }
    File(
      p.join(root.path, 'packed_resource.dart'),
    ).writeAsStringSync(packedResourceRuntime);
    final registry = StringBuffer();
    for (final (_, name) in assets) {
      registry.writeln("import '$name.g.dart';");
    }
    registry.writeln(
      "import 'packed_resource.dart';\n"
      'class ResourceRegistry {\n'
      '  static const resources = <String, PackedResource>{',
    );
    for (final (relative, name) in assets) {
      registry.writeln('    ${dartString(relative)}: $name(),');
    }
    registry.writeln('  };\n}');
    File(
      p.join(root.path, 'resource_registry.dart'),
    ).writeAsStringSync('$registry');
    final json = jsonEncode(manifest);
    final key = sha256.convert(utf8.encode('dcli-packed-v1:$executable:$json'));
    final source = nativeLauncherSource(
      executable,
      imports: "import 'resource_registry.dart';",
      preparationSource:
          '''
const bundleKey = '$key';
final manifest = jsonDecode(${dartString(json)}) as Map<String, dynamic>;
$packedBundleRuntime
''',
    );
    final launcher = File(p.join(root.path, 'launcher.dart'))
      ..writeAsStringSync(source);
    File(
      p.join(root.path, 'package_config.json'),
    ).writeAsStringSync('{"configVersion":2,"packages":[]}');
    return launcher.path;
  }
}
