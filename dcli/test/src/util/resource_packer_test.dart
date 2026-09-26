import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/resources/resource_packer.dart';
import 'package:path/path.dart' as p;
import 'package:scope/scope.dart';
import 'package:test/test.dart';

void main() {
  test(
    'pack splits, compresses, and regenerates resources without stale parts',
    () async {
      final temp = Directory.systemTemp.createTempSync('dcli parts ');
      try {
        final root = Directory(p.join(temp.path, 'resource'))..createSync();
        final random = Random(42);
        final data = List<int>.generate(
          ResourcePacker.chunkSize * 3 + 7,
          (_) => random.nextInt(256),
        );
        const binaryName = r"large $' binary.dat";
        File(p.join(root.path, binaryName)).writeAsBytesSync(data);
        File(p.join(root.path, 'empty')).writeAsBytesSync([]);
        File(
          p.join(root.path, 'compressible'),
        ).writeAsBytesSync(List<int>.filled(ResourcePacker.chunkSize * 2, 0));
        void pack() {
          Scope()
            ..value(Resources.scopeKeyProjectRoot, temp.path)
            ..runSync(() => Resources().pack());
        }

        pack();
        final generated = Directory(
          p.join(temp.path, 'lib/src/dcli/resource/generated'),
        );
        final parts = generated
            .listSync()
            .whereType<File>()
            .where((file) => p.basename(file.path).contains('Part'))
            .toList();
        expect(parts.length, 6);
        expect(parts.every((file) => file.lengthSync() < 400 * 1024), isTrue);
        expect(
          parts.where((file) => file.lengthSync() < 2048).length,
          greaterThanOrEqualTo(2),
          reason: 'Zero-filled chunks compress well.',
        );
        final runner = File(p.join(temp.path, 'unpack.dart'))
          ..writeAsStringSync(r'''
import 'dart:io';
import 'lib/src/dcli/resource/generated/resource_registry.g.dart';
void main(List<String> args) {
  for (final entry in ResourceRegistry.resources.entries) {
    entry.value.unpack('${args.single}/${entry.key}');
  }
}
''');
        final output = Directory(p.join(temp.path, 'unpacked'))..createSync();
        final result = await Process.run(Platform.resolvedExecutable, [
          '--packages=${p.absolute('.dart_tool/package_config.json')}',
          runner.path,
          output.path,
        ]);
        expect(
          result.exitCode,
          0,
          reason: '${result.stdout}\n${result.stderr}',
        );
        expect(File(p.join(output.path, binaryName)).readAsBytesSync(), data);
        expect(File(p.join(output.path, 'empty')).lengthSync(), 0);
        expect(
          File(p.join(output.path, 'compressible')).readAsBytesSync(),
          List<int>.filled(ResourcePacker.chunkSize * 2, 0),
        );
        File(p.join(root.path, binaryName)).writeAsStringSync('small');
        pack();
        expect(
          generated
              .listSync()
              .whereType<File>()
              .where((file) => p.basename(file.path).contains('Part'))
              .length,
          3,
        );
      } finally {
        temp.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('bad compressed part lengths fail instead of writing corrupt data', () {
    final temp = Directory.systemTemp.createTempSync('dcli bad part ');
    try {
      final resource = _Resource(_Part(base64.encode(gzip.encode([1, 2, 3]))));
      expect(
        () => resource.unpack(p.join(temp.path, 'out')),
        throwsA(isA<FormatException>()),
      );
    } finally {
      temp.deleteSync(recursive: true);
    }
  });
}

class _Resource extends PackedResource {
  const _Resource(this.part);
  final PackedResourcePart part;
  @override
  Iterable<PackedResourcePart> get parts => [part];
  @override
  String get checksum => '';
  @override
  String get originalPath => 'out';
}

class _Part extends PackedResourcePart {
  const _Part(this.content);
  @override
  final String content;
  @override
  int get length => 4;
}
