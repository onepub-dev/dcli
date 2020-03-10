@t.Timeout(Duration(seconds: 600))
import 'package:dshell/src/functions/env.dart';
import 'package:mockito/mockito.dart';

import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../mocks/mock_settings.dart';
import '../util/test_file_system.dart';

void main() {
  Settings().debug_on = true;

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
          Settings.setMock(mockSettings);
          when(mockSettings.isWindows).thenReturn(true);
          when(mockSettings.debug_on).thenReturn(true);
          Env.reset();
          //var mockEnv = MockEnv();

          var userDataPath = 'C:\\Windows\\Userdata';

          // windows we can't add a path just expect user message.

          // when(mockEnv.HOME).thenReturn('C:\\Windows\\Userdata');
          // when(mockEnv.env('APPDATA')).thenReturn(userDataPath);
          // when(mockEnv.env('MixedCase')).thenReturn(userDataPath);

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
          t.expect(available, t.contains(expected));
        } finally {
          Settings.reset();
          Env.reset();
        }
      });
    });
  });
}
