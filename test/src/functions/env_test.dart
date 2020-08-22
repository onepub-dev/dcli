@t.Timeout(Duration(seconds: 600))
import 'package:dcli/src/functions/env.dart';
import 'package:mockito/mockito.dart';

import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';

import '../mocks/mock_settings.dart';
import '../util/test_file_system.dart';

void main() {
  t.group('Environment', () {
    t.test('PATH', () {
      TestFileSystem().withinZone((fs) {
        t.expect(env('PATH').length, t.greaterThan(0));
      });
    });

    t.test('Windows case-insensitive env vars', () {
      TestFileSystem().withinZone((fs) {
        try {
          Settings.reset();
          var mockSettings = MockSettings();
          Settings.mock = mockSettings;
          when(mockSettings.isWindows).thenReturn(true);
          Env.reset();
          //var mockEnv = MockEnv();

          var userDataPath = 'C:\\Windows\\Userdata';

          setEnv('HOME', userDataPath);
          setEnv('APPDATA', userDataPath);
          setEnv('MixedCase', 'mixed data');

          // test that env
          t.expect(env('HOME'), userDataPath);
          t.expect(env('AppData'), userDataPath);
          t.expect(env('APPDATA'), userDataPath);

          var available = <String, String>{};
          available.putIfAbsent('APPDATA', () => env('APPDATA'));
          available.putIfAbsent('MixedCase', () => env('MixedCase'));

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
  });
}
