@Timeout(Duration(minutes: 10))
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/functions/env.dart';
import 'package:dcli/src/pubspec/global_dependencies.dart';
import 'package:dcli/src/script/entry_point.dart';
import 'package:mockito/mockito.dart';
import 'package:pubspec/pubspec.dart';
import 'package:test/test.dart';

import '../../mocks/mock_env.dart';
import '../../mocks/mock_settings.dart';
import '../../util/test_file_system.dart';

String script = 'test/test_scripts/bin/hello_world.dart';

void main() {
  group('Install DCli', () {
    test('clean install', () {
      var groupFS = TestFileSystem(useCommonPath: false);

      groupFS.withinZone((fs) {
        try {
          EntryPoint().process(['install']);
        } on DCliException catch (e) {
          print(e);
        }

        checkInstallStructure();

        // Now install over existing
        try {
          EntryPoint().process(['install']);
        } on DCliException catch (e) {
          print(e);
        }

        checkInstallStructure();
      });
    });

    test('Install with error', () {
      TestFileSystem(useCommonPath: false).withinZone((fs) {
        try {
          EntryPoint().process(['install', 'a']);
        } on DCliException catch (e) {
          print(e);
        }
        expect(exists('${fs.home}/.dcli'), equals(false));
      });
    });

    test('add ~/.dcli/bin to PATH Windows', () {
      TestFileSystem().withinZone((fs) {
        var settings = Settings();
        var mockSettings = MockSettings();
        var mockEnv = MockEnv();

        // windows we can't add a path just expect user message.
        when(mockSettings.isWindows).thenReturn(true);
        when(mockSettings.isLinux).thenReturn(false);
        when(mockSettings.isMacOS).thenReturn(false);
        when(mockSettings.dcliBinPath).thenReturn(settings.dcliBinPath);

        when(mockEnv.HOME).thenReturn('c:\\windows\\userdata');
        when(mockEnv.isOnPath(settings.dcliBinPath)).thenReturn(false);

        Settings.mock = mockSettings;
        Env.mock = mockEnv;
      });
    });

    test('set env PATH Linux', () {
      TestFileSystem().withinZone((fs) {
        var settings = Settings();
        var mockSettings = MockSettings();
        var mockEnv = MockEnv();

        when(mockSettings.isWindows).thenReturn(false);
        when(mockSettings.isLinux).thenReturn(true);
        when(mockSettings.isMacOS).thenReturn(false);
        when(mockSettings.dcliBinPath).thenReturn(settings.dcliBinPath);

        when(mockEnv.HOME).thenReturn(HOME);
        when(mockEnv.isOnPath(settings.dcliBinPath)).thenReturn(false);

        Settings.mock = mockSettings;
        Env.mock = mockEnv;

        var export = 'export PATH=\$PATH:${settings.dcliBinPath}';

        var profilePath = join(HOME, '.profile');
        if (exists(profilePath)) {
          expect(read(profilePath).toList(), contains(export));
        }
        Env.reset();
        Settings.reset();
      });
    });

    test('With Lib', () {});
  }, skip: false);
}

void checkInstallStructure() {
  expect(exists(truepath(HOME, '.dcli')), equals(true));

  expect(exists(truepath(HOME, '.dcli', 'cache')), equals(true));

  expect(exists(truepath(HOME, '.dcli', 'templates')), equals(true));

  expect(exists(truepath(HOME, '.dcli', GlobalDependencies.filename)), equals(true));

  var content = read(truepath(HOME, '.dcli', GlobalDependencies.filename)).toList();
  var expected = ['dependencies:'];

  for (var dep in GlobalDependencies.defaultDependencies) {
    if (dep.name == 'dcli') {
      /// The TestFileSystem uses the locally installed version of dcli
      /// The unit tests are always launched from the dcli directory
      /// hence pwd will point to the locally installed dcli.
      expected.add('  ${dep.name}:');
      expected.add('    path: $pwd');
    } else {
      expected.add('  ${dep.name}: ${(dep.reference as HostedReference).versionConstraint.toString()}');
    }
  }

  expect(content, equals(expected));
}
