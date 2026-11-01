import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('failed warmup stops compile before generation or installation',
      () async {
    final sdk = Directory.current.path;
    final cli = p.join(sdk, 'bin', 'dcli.dart');
    final temporary =
        Directory.systemTemp.createTempSync('dcli compile failure ');
    try {
      final project = Directory(p.join(temporary.path, 'project'))
        ..createSync();
      File(p.join(project.path, 'pubspec.yaml')).writeAsStringSync(
        jsonEncode({
          'name': 'compile_failure_fixture',
          'environment': {'sdk': '>=3.10.0 <4.0.0'},
          'dependencies': {
            'missing_dependency': {
              'path': p.join(temporary.path, 'does-not-exist'),
            },
          },
        }),
      );
      File(p.join(project.path, 'tool.dart')).writeAsStringSync(
        'void main() {}\n',
      );

      final result = await Process.run(
        Platform.resolvedExecutable,
        [
          '--packages=${p.join(sdk, '.dart_tool', 'package_config.json')}',
          cli,
          'compile',
          '-s',
          '-o',
          '-i',
          'tool.dart',
        ],
        workingDirectory: project.path,
      );
      final output = '${result.stdout}\n${result.stderr}';
      expect(result.exitCode, isNot(0), reason: output);
      expect(output, contains('warmup failed'));
      expect(output, isNot(contains('Generated:')));
      expect(output, isNot(contains('Outputs:')));
      expect(output, isNot(contains('Executable:')));
      expect(File(p.join(project.path, 'tool')).existsSync(), isFalse);
      expect(output, isNot(contains('dcli-system-helper-')));
    } finally {
      temporary.deleteSync(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
