import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/functions/is.dart';
import 'package:dshell/src/script/entry_point.dart';
import 'package:dshell/src/util/dshell_exception.dart';
import 'package:test/test.dart';

import '../util/test_fs_zone.dart';
import '../util/test_paths.dart';
import '../util/wipe.dart';

String script = 'test/test_scripts/hello_world.dart';

void main() {
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

        checkInstallStructure(TestPaths(script));
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

        checkInstallStructure(TestPaths(script));
      });
    });

    test('Install with error', () {
      TestZone().run(() {
        var paths = TestPaths(script);
        wipe();
        try {
          EntryPoint().process(['install', 'a']);
        } on DShellException catch (e) {
          print(e);
        }
        expect(exists('${paths.home}/.dshell'), equals(false));
      });
    });

    test('With Lib', () {});
  });
}

void checkInstallStructure(TestPaths testPaths) {
  expect(exists('${testPaths.home}/.dshell'), equals(true));

  expect(exists('${testPaths.home}/.dshell/cache'), equals(true));

  expect(exists('${testPaths.home}/.dshell/templates'), equals(true));

  expect(exists('${testPaths.home}/.dshell/dependancies.yaml'), equals(true));
}
