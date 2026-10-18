@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart';
import 'package:scope/scope.dart';
import 'package:test/test.dart';

const _commands = ['head', 'tail', 'ls', 'touch', 'run_child'];

void main() {
  for (final platform in core.DCliPlatformOS.values) {
    test('reuses current cached tools on ${platform.name}', () async {
      await withTempDirAsync((cache) async {
        final originalTools = TestFileSystem.pathToTools;
        TestFileSystem.pathToTools = cache;
        addTearDown(() => TestFileSystem.pathToTools = originalTools);
        final suffix = platform == core.DCliPlatformOS.windows ? '.exe' : '';
        final timestamp = DateTime.now().add(const Duration(days: 1));
        for (final command in _commands) {
          File(join(cache, '$command$suffix'))
            ..writeAsStringSync('cached $command')
            ..setLastModifiedSync(timestamp);
        }

        final filesystems = List.generate(
          2,
          (_) => TestFileSystem(useCommonPath: false),
        );
        final scope = Scope()
          ..value(
            core.DCliPlatform.scopeKey,
            core.DCliPlatform.forScope(overriddenPlatform: platform),
          );
        await scope.run(() async {
          // Separate filesystems must share the same installed tools without
          // recompiling or overwriting an executable another test may be using.
          for (final filesystem in filesystems) {
            await filesystem.installCrossPlatformTestScripts();
          }
        });

        for (final command in _commands) {
          final executable = File(join(cache, '$command$suffix'));
          expect(executable.readAsStringSync(), 'cached $command');
          expect(
            executable.lastModifiedSync().difference(timestamp).inSeconds,
            0,
          );
        }
      });
    });
  }

  for (final missing in [false, true]) {
    test('${missing ? 'builds a missing' : 'rebuilds a stale'} tool '
        'and preserves current tools', () async {
      await withTempDirAsync((cache) async {
        final originalTools = TestFileSystem.pathToTools;
        TestFileSystem.pathToTools = cache;
        addTearDown(() => TestFileSystem.pathToTools = originalTools);
        final suffix = Platform.isWindows ? '.exe' : '';
        for (final command in _commands) {
          if (missing && command == 'touch') {
            continue;
          }
          File(join(cache, '$command$suffix'))
            ..writeAsStringSync('cached $command')
            ..setLastModifiedSync(
              command == 'touch'
                  ? DateTime(2000)
                  : DateTime.now().add(const Duration(days: 1)),
            );
        }
        if (!missing && !Platform.isWindows) {
          final chmod = await Process.run('chmod', [
            'u+x',
            join(cache, 'touch$suffix'),
          ]);
          expect(chmod.exitCode, 0);
        }
        // A leftover source file must not suppress rebuilding the executable.
        File(
          join(cache, 'touch.dart'),
        ).writeAsStringSync('// stale source copy');

        await TestFileSystem(
          useCommonPath: false,
        ).installCrossPlatformTestScripts();

        final input = File(join(cache, 'input.txt'))
          ..writeAsStringSync('input')
          ..setLastModifiedSync(DateTime(2000));
        final result = await Process.run(join(cache, 'touch$suffix'), [
          'input.txt',
        ], workingDirectory: cache);
        expect(result.exitCode, 0, reason: result.stderr.toString());
        expect(input.lastModifiedSync().isAfter(DateTime(2000)), isTrue);
        for (final command in _commands.where(
          (command) => command != 'touch',
        )) {
          expect(
            File(join(cache, '$command$suffix')).readAsStringSync(),
            'cached $command',
          );
        }
      });
    });
  }
}
