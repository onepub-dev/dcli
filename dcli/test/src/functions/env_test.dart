import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_core/dcli_core.dart' hide withEnvironment;
import 'package:scope/scope.dart';

import 'package:test/test.dart' as t;

void main() {
  t.group('Environment', () {
    t.test('PATH', () {
      t.expect(core.env['PATH']!.length, t.greaterThan(0));
    });

    t.test('addAll', () {
      final count = core.env.entries.length;
      core.env.addAll({'hi': 'there'});
      t.expect(core.env.entries.length, t.equals(count + 1));

      core.env.addAll({'hi': 'there', 'ho': 'there'});
      t.expect(core.env.entries.length, t.equals(count + 2));
    });

    t.test('Windows case-insensitive env vars', () {
      Scope()
        ..value(DCliPlatform.scopeKey,
            DCliPlatform.forScope(overriddenPlatform: DCliPlatformOS.windows))
        ..runSync(() {
          ///  We need to run with an environment that thinks its running
          /// under windows.
          withEnvironment(() {
            const userDataPath = r'C:\Windows\Userdata';

            core.env['HOME'] = userDataPath;
            core.env['APPDATA'] = userDataPath;
            core.env['MixedCase'] = 'mixed data';

            // test that env
            t.expect(core.env['HOME'], userDataPath);
            t.expect(core.env['APPDATA'], userDataPath);
            t.expect(core.env['AppData'], userDataPath);

            final available = <String, String?>{}
              ..putIfAbsent('APPDATA', () => core.env['APPDATA'])
              ..putIfAbsent('MixedCase', () => core.env['MixedCase']);

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
