import 'package:mockito/mockito.dart';

import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/pubspec/global_dependencies.dart';
import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/util/dshell_exception.dart';
import 'package:pubspec/pubspec.dart';
import 'package:test/test.dart';

import '../test/mocks/mock_env.dart';
import '../test/mocks/mock_settings.dart';
import '../test/util/test_fs_zone.dart';
import '../test/util/test_paths.dart';
import '../test/util/wipe.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {
  setUpAll(() {
    TestPaths();
  });

  group('Install DShell', () {
    test('clean install', () {
      TestZone().run(() {
        try {
          // setEnv('HOME', '/home/test');
          // createDir('/home/test', recursive: true);
          wipe();
          EntryPoint().process(['install']);
        } on DShellException catch (e) {
          print(e);
        }

        checkInstallStructure();
      });
    });
    test('install over existing', () {
      TestZone().run(() {
        try {
          // setEnv('HOME', '/home/test');
          // createDir('/home/test', recursive: true);
          EntryPoint().process(['install']);
        } on DShellException catch (e) {
          print(e);
        }

        checkInstallStructure();
      });
    });

    test('Install with error', () {
      TestZone().run(() {
        var paths = TestPaths();
        wipe();
        try {
          EntryPoint().process(['install', 'a']);
        } on DShellException catch (e) {
          print(e);
        }
        expect(exists('${paths.home}/.dshell'), equals(false));
      });
    });

    test('add ~/.dshell/bin to PATH Windows', () {
      var settings = Settings();
      var mockSettings = MockSettings();
      var mockEnv = MockEnv();

      // windows we can't add a path just expect user message.
      when(mockSettings.isWindows).thenReturn(true);
      when(mockSettings.isLinux).thenReturn(false);
      when(mockSettings.isMacOS).thenReturn(false);
      when(mockSettings.dshellBinPath).thenReturn(settings.dshellBinPath);
      when(mockSettings.debug_on).thenReturn(false);

      when(mockEnv.HOME).thenReturn('c:\\windows\\userdata');
      when(mockEnv.isOnPath(settings.dshellBinPath)).thenReturn(false);

      Settings.setMock(mockSettings);
      Env.setMock(mockEnv);
    }, skip: true);

    test('set env PATH Linux', () {
      var settings = Settings();
      var mockSettings = MockSettings();
      var mockEnv = MockEnv();

      when(mockSettings.isWindows).thenReturn(false);
      when(mockSettings.isLinux).thenReturn(true);
      when(mockSettings.isMacOS).thenReturn(false);
      when(mockSettings.dshellBinPath).thenReturn(settings.dshellBinPath);
      when(mockSettings.debug_on).thenReturn(false);

      when(mockEnv.HOME).thenReturn(HOME);
      when(mockEnv.isOnPath(settings.dshellBinPath)).thenReturn(false);

      Settings.setMock(mockSettings);
      Env.setMock(mockEnv);

      var export = 'export PATH=\$PATH:${settings.dshellBinPath}';

      var profilePath = join(HOME, '.profile');
      if (exists(profilePath)) {
        expect(read(profilePath).toList(), contains(export));
      }
    });

    test('With Lib', () {});
  }, skip: false);
}

void checkInstallStructure() {
  expect(exists(truepath(HOME, '.dshell')), equals(true));

  expect(exists(truepath(HOME, '.dshell', 'cache')), equals(true));

  expect(exists(truepath(HOME, '.dshell', 'templates')), equals(true));

  expect(exists(truepath(HOME, '.dshell', 'dependencies.yaml')), equals(true));

  var content = read(truepath(HOME, '.dshell', 'dependencies.yaml')).toList();
  var expected = ['dependencies:'];

  for (var dep in GlobalDependencies.defaultDependencies) {
    expected.add(
        '  ${dep.name}: ${(dep.reference as HostedReference).versionConstraint.toString()}');
  }

  expect(content, equals(expected));
}
