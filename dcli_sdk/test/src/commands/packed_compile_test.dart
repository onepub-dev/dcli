import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'CLI packs resources explicitly and compiles a packed executable',
    () async {
      final sdk = Directory.current.path;
      final repository = p.dirname(sdk);
      final cli = p.join(sdk, 'bin', 'dcli.dart');
      final temporary = Directory.systemTemp.createTempSync('dcli packed cli ');
      try {
        final project = Directory(p.join(temporary.path, 'project'))
          ..createSync();
        final pubspec = <String, Object>{
          'name': 'packed_cli_fixture',
          'environment': {'sdk': '>=3.10.0 <4.0.0'},
          'dependencies': {
            'dcli': {'path': p.join(repository, 'dcli')},
          },
          'dependency_overrides': {
            for (final name in ['dcli_common', 'dcli_core', 'dcli_terminal'])
              name: {'path': p.join(repository, name)},
          },
        };
        File(
          p.join(project.path, 'pubspec.yaml'),
        ).writeAsStringSync(jsonEncode(pubspec));
        final resource = File(p.join(project.path, 'resource', 'message.txt'))
          ..createSync(recursive: true)
          ..writeAsStringSync('packed resource');
        File(p.join(project.path, 'tool.dart')).writeAsStringSync('''
import 'dart:io';
import 'lib/src/dcli/resource/generated/resource_registry.g.dart';
void main(List<String> args) {
  ResourceRegistry.resources['message.txt']!.unpack(args.single);
  print(File(args.single).readAsStringSync());
}
''');
        Future<ProcessResult> command(List<String> args) async {
          final result = await Process.run(
            'dart',
            args,
            workingDirectory: project.path,
          );
          expect(
            result.exitCode,
            0,
            reason: '${result.stdout}\n${result.stderr}',
          );
          return result;
        }

        await command(['pub', 'get']);
        await command(['run', cli, 'pack']);
        // Compilation uses generated resources without silently repacking.
        resource.writeAsStringSync('unpacked change');
        final compilation = await command([
          'run',
          cli,
          'compile',
          '--packed',
          '--nowarmup',
          'tool.dart',
        ]);
        final executable = p.join(
          project.path,
          Platform.isWindows ? 'tool.exe' : 'tool',
        );
        expect(
          '${compilation.stdout}',
          contains('Packed executable: $executable'),
        );
        expect('${compilation.stdout}', isNot(contains('Generated: ')));
        expect(
          Directory(p.join(project.path, '.tool.bundle')).existsSync(),
          isFalse,
        );
        final relocated = p.join(
          temporary.path,
          Platform.isWindows ? 'renamed.exe' : 'renamed',
        );
        File(executable).renameSync(relocated);
        project.deleteSync(recursive: true);
        final result = await Process.run(
          relocated,
          [p.join(temporary.path, 'unpacked.txt')],
          environment: {'DCLI_BUNDLE_CACHE': p.join(temporary.path, 'cache')},
        );
        expect(result.exitCode, 0, reason: '${result.stderr}');
        expect('${result.stdout}'.trim(), 'packed resource');
      } finally {
        temporary.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
