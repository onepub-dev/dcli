@Timeout(Duration(minutes: 10))
import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/pubspec/global_dependencies.dart';
import 'package:dshell/src/script/entry_point.dart';
import 'package:mockito/mockito.dart';
import 'package:pubspec/pubspec.dart';
import 'package:test/test.dart';

import '../../mocks/mock_env.dart';
import '../../mocks/mock_settings.dart';
import '../../util/test_file_system.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {
  group('Install DShell', () {
    test('clean install', () {
      var groupFS = TestFileSystem(useCommonPath: false);

      groupFS.withinZone((fs) {
        try {
          EntryPoint().process(['install']);
        } on DShellException catch (e) {
          print(e);
        }

        checkInstallStructure();

        // Now install over existing
        try {
          EntryPoint().process(['install']);
        } on DShellException catch (e) {
          print(e);
        }

        checkInstallStructure();
      });
    });

    test('Install with error', () {
      TestFileSystem(useCommonPath: false).withinZone((fs) {
        try {
          EntryPoint().process(['install', 'a']);
        } on DShellException catch (e) {
          print(e);
        }
        expect(exists('${fs.home}/.dshell'), equals(false));
      });
    });

    test('add ~/.dshell/bin to PATH Windows', () {
      TestFileSystem().withinZone((fs) {
        var settings = Settings();
        var mockSettings = MockSettings();
        var mockEnv = MockEnv();

        // windows we can't add a path just expect user message.
        when(mockSettings.isWindows).thenReturn(true);
        when(mockSettings.isLinux).thenReturn(false);
        when(mockSettings.isMacOS).thenReturn(false);
        when(mockSettings.dshellBinPath).thenReturn(settings.dshellBinPath);

        when(mockEnv.HOME).thenReturn('c:\\windows\\userdata');
        when(mockEnv.isOnPath(settings.dshellBinPath)).thenReturn(false);

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
        when(mockSettings.dshellBinPath).thenReturn(settings.dshellBinPath);

        when(mockEnv.HOME).thenReturn(HOME);
        when(mockEnv.isOnPath(settings.dshellBinPath)).thenReturn(false);

        Settings.mock = mockSettings;
        Env.mock = mockEnv;

        var export = 'export PATH=\$PATH:${settings.dshellBinPath}';

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
  expect(exists(truepath(HOME, '.dshell')), equals(true));

  expect(exists(truepath(HOME, '.dshell', 'cache')), equals(true));

  expect(exists(truepath(HOME, '.dshell', 'templates')), equals(true));

  expect(exists(truepath(HOME, '.dshell', GlobalDependencies.filename)),
      equals(true));

  var content =
      read(truepath(HOME, '.dshell', GlobalDependencies.filename)).toList();
  var expected = ['dependencies:'];

  for (var dep in GlobalDependencies.defaultDependencies) {
    if (dep.name == 'dshell') {
      /// The TestFileSystem uses the locally installed version of dshell
      /// The unit tests are always launched from the dshell directory
      /// hence pwd will point to the locally installed dshell.
      expected.add('  ${dep.name}:');
      expected.add('    path: $pwd');
    } else {
      expected.add(
          '  ${dep.name}: ${(dep.reference as HostedReference).versionConstraint.toString()}');
    }
  }

  expect(content, equals(expected));
}
