@t.Timeout(Duration(seconds: 600))
import 'package:dcli/src/functions/env.dart';
import 'package:mockito/mockito.dart';

import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';

import '../mocks/mock_settings.dart';

void main() {
  t.group('Environment', () {
    t.test('PATH', () {
      t.expect(env['PATH'].length, t.greaterThan(0));
    });

    t.test('addAll', () {
      var count = env.entries.length;
      env.addAll({'hi': 'there'});
      t.expect(env.entries.length, t.equals(count + 1));

      env.addAll({'hi': 'there', 'ho': 'there'});
      t.expect(env.entries.length, t.equals(count + 2));
    });

    t.test('Windows case-insensitive env vars', () {
      try {
        Settings.reset();
        var mockSettings = MockSettings();
        Settings.mock = mockSettings;
        when(mockSettings.isWindows).thenReturn(true);
        Env.reset();
        //var mockEnv = MockEnv();

        var userDataPath = 'C:\\Windows\\Userdata';

        env['HOME'] = userDataPath;
        env['APPDATA'] = userDataPath;
        env['MixedCase'] = 'mixed data';

        // test that env
        t.expect(env['HOME'], userDataPath);
        t.expect(env['APPDATA'], userDataPath);
        t.expect(env['AppData'], userDataPath);

        var available = <String, String>{};
        available.putIfAbsent('APPDATA', () => env['APPDATA']);
        available.putIfAbsent('MixedCase', () => env['MixedCase']);

        var expected = <String, String>{};

        expected.putIfAbsent('APPDATA', () => userDataPath);
        expected.putIfAbsent('MixedCase', () => 'mixed data');
        t.expect(available, expected);
      } finally {
        Settings.reset();
        Env.reset();
      }
    });
  });
}
