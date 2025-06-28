/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_core/dcli_core.dart';
import 'package:scope/scope.dart';
import 'package:test/test.dart' as t;

void main() {
  t.group('Environment', () {
    t.test('PATH', () {
      t.expect(env['PATH']!.length, t.greaterThan(0));
    });

    t.test('addAll', () {
      final count = env.entries.length;
      env.addAll({'hi': 'there'});
      t.expect(env.entries.length, t.equals(count + 1));

      env.addAll({'hi': 'there', 'ho': 'there'});
      t.expect(env.entries.length, t.equals(count + 2));
    });

    t.test('Windows case-insensitive env vars', () async {
      final scope = Scope()
        ..value(DCliPlatform.scopeKey,
            DCliPlatform.forScope(overriddenPlatform: DCliPlatformOS.windows));
      await scope.run(() async {
        ///  We need to run with an environment that thinks its running
        /// under windows.
        await withEnvironmentAsync(() async {
          const userDataPath = r'C:\Windows\Userdata';

          env['HOME'] = userDataPath;
          env['APPDATA'] = userDataPath;
          env['MixedCase'] = 'mixed data';

          // test that env
          t.expect(env['HOME'], userDataPath);
          t.expect(env['APPDATA'], userDataPath);
          t.expect(env['AppData'], userDataPath);

          final available = <String, String?>{}
            ..putIfAbsent('APPDATA', () => env['APPDATA'])
            ..putIfAbsent('MixedCase', () => env['MixedCase']);

          final expected = <String, String>{}
            ..putIfAbsent('APPDATA', () => userDataPath)
            ..putIfAbsent('MixedCase', () => 'mixed data');
          t.expect(available, expected);
        }, environment: {});
      });
    });
    //  });
  });
}
