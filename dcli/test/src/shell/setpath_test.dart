import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:scope/scope.dart';
import 'package:test/test.dart';

void main() {
  for (final platform in [
    core.DCliPlatformOS.windows,
    core.DCliPlatformOS.linux,
  ]) {
    test('appendToPATH is local and idempotent on $platform', () async {
      final original = PATH;
      final processPath = Platform.environment['PATH'];
      final scope = Scope()
        ..value(
          core.DCliPlatform.scopeKey,
          core.DCliPlatform.forScope(overriddenPlatform: platform),
        );
      await scope.run(() async {
        core.withEnvironment(() {
          final windows = platform == core.DCliPlatformOS.windows;
          final paths = windows
              ? [
                  r'C:\tools\dart-sdk\bin',
                  r'C:\fixture\pub-cache\bin',
                  r'C:\fixture\dcli\bin',
                ]
              : [
                  '/tools/dart-sdk/bin',
                  '/fixture/pub-cache/bin',
                  '/fixture/dcli/bin',
                ];
          final delimiter = windows ? ';' : ':';
          for (final path in paths) {
            Env().appendToPATH(path);
            Env().appendToPATH(path);
          }
          expect(PATH, ['fixture', ...paths]);
          expect(core.env['PATH'], ['fixture', ...paths].join(delimiter));
        }, environment: {'PATH': 'fixture'});
      });
      expect(PATH, original);
      expect(Platform.environment['PATH'], processPath);
    });
  }

  test('PATH scope is restored when a test operation throws', () {
    final original = PATH;
    expect(
      () => core.withEnvironment(() {
        Env().appendToPATH('/fixture/throwing-test');
        throw StateError('simulated assertion failure');
      }, environment: {'PATH': 'fixture'}),
      throwsStateError,
    );
    expect(PATH, original);
  });
}
