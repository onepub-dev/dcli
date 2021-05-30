@Timeout(Duration(minutes: 10))
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/functions/env.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../mocks/mock_env.dart';
import '../../mocks/mock_settings.dart';
import '../../util/test_file_system.dart';

void main() {
  group('Install DCli', () {
    test('warmup install', () {
      TestFileSystem(useCommonPath: false).withinZone((fs) {
        try {
          Shell.current.install();
        } on DCliException catch (e) {
          print(e);
        }

        checkInstallStructure(fs);

        // Now install over existing
        try {
          Shell.current.install();
        } on DCliException catch (e) {
          print(e);
        }

        checkInstallStructure(fs);
      });
    });
    test('add ~/.dcli/bin to PATH on Windows', () {
      TestFileSystem().withinZone((fs) {
        final settings = Settings();
        final mockSettings = MockSettings();
        final mockEnv = MockEnv();

        // windows we can't add a path just expect user message.
        when(() => mockSettings.isWindows).thenReturn(true);
        when(() => mockSettings.isLinux).thenReturn(false);
        when(() => mockSettings.isMacOS).thenReturn(false);
        when(() => mockSettings.isVerbose).thenReturn(false);
        when(() => mockSettings.pathToDCliBin)
            .thenReturn(settings.pathToDCliBin);

        when(() => mockEnv.HOME).thenReturn(r'C:\windows\userdata');
        when(() => mockEnv.isOnPATH(settings.pathToDCliBin)).thenReturn(false);

        Settings.mock = mockSettings;
        Env.mock = mockEnv;
      });
    });

    test('set env PATH Linux', () {
      TestFileSystem().withinZone((fs) {
        final settings = Settings();
        final mockSettings = MockSettings();
        final mockEnv = MockEnv();

        when(() => mockSettings.isWindows).thenReturn(false);
        when(() => mockSettings.isLinux).thenReturn(true);
        when(() => mockSettings.isMacOS).thenReturn(false);
        when(() => mockSettings.isVerbose).thenReturn(false);
        when(() => mockSettings.pathToDCliBin)
            .thenReturn(settings.pathToDCliBin);

        when(() => mockEnv.HOME).thenReturn(HOME);
        when(() => mockEnv.isOnPATH(settings.pathToDCliBin)).thenReturn(false);

        Settings.mock = mockSettings;
        Env.mock = mockEnv;

        final export = 'export PATH=\$PATH:${settings.pathToDCliBin}';

        final profilePath = join(HOME, '.profile');
        if (exists(profilePath)) {
          final exportLines = read(profilePath).toList()
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

  final templates =
      find('*.*', workingDirectory: join(fs.home!, '.dcli', 'templates'))
          .toList();

  final base = join(fs.home!, '.dcli', 'templates');

  expect(
    templates,
    unorderedEquals(
      <String>[
        absolute(base, 'basic.dart'),
        absolute(base, 'hello_world.dart'),
        absolute(base, 'pubspec.yaml.template'),
        absolute(base, 'README.md'),
        absolute(base, 'analysis_options.yaml'),
        absolute(base, 'cmd_args.dart'),
      ],
    ),
  );
}
