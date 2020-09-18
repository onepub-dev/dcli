@Timeout(Duration(minutes: 10))
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/functions/env.dart';
import 'package:dcli/src/script/entry_point.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mocks/mock_env.dart';
import '../../mocks/mock_settings.dart';
import '../../util/test_file_system.dart';

String script = 'test/test_scripts/general/bin/hello_world.dart';

void main() {
  group('Install DCli', () {
    test('warmup install', () {
      var groupFS = TestFileSystem(useCommonPath: false);

      groupFS.withinZone((fs) {
        try {
          EntryPoint().process(['install']);
        } on DCliException catch (e) {
          print(e);
        }

        checkInstallStructure(fs);

        // Now install over existing
        try {
          EntryPoint().process(['install']);
        } on DCliException catch (e) {
          print(e);
        }

        checkInstallStructure(fs);
      });
    });

    test('Install with error', () {
      TestFileSystem(
        useCommonPath: false,
      ).withinZone((fs) {
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
        when(mockSettings.pathToDCliBin).thenReturn(settings.pathToDCliBin);

        when(mockEnv.HOME).thenReturn('c:\\windows\\userdata');
        when(mockEnv.isOnPATH(settings.pathToDCliBin)).thenReturn(false);

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
        when(mockSettings.pathToDCliBin).thenReturn(settings.pathToDCliBin);

        when(mockEnv.HOME).thenReturn(HOME);
        when(mockEnv.isOnPATH(settings.pathToDCliBin)).thenReturn(false);

        Settings.mock = mockSettings;
        Env.mock = mockEnv;

        var export = 'export PATH=\$PATH:${settings.pathToDCliBin}';

        var profilePath = join(HOME, '.profile');
        if (exists(profilePath)) {
          var exportLines = read(profilePath).toList()
            ..retainWhere((line) => line.startsWith('export'));
          expect(exportLines, contains(export));
        }
        Env.reset();
        Settings.reset();
      });
    });

    test('With Lib', () {});
  }, skip: false);
}

void checkInstallStructure(TestFileSystem fs) {
  expect(exists(truepath(HOME, '.dcli')), equals(true));

  expect(exists(truepath(HOME, '.dcli', 'cache')), equals(true));

  expect(exists(truepath(HOME, '.dcli', 'templates')), equals(true));

  var templates =
      find('*.dart', root: join('${fs.home}/.dcli', 'templates')).toList();

  var base = join('${fs.home}/.dcli', 'templates');

  expect(
    templates,
    unorderedEquals(
      <String>[
        join(base, 'cli_args.dart'),
        join(base, 'hello_world.dart'),
        join(base, 'pubspec.yaml.template'),
        join(base, 'README.md'),
        join(base, 'analysis_options.yaml'),
      ],
    ),
  );
}
