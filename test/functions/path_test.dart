import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../test_settings.dart';
import '../util/test_fs_zone.dart';

String TEST_DIR = 'path_test';
void main() {
  Settings().debug_on = true;
  var cwd = pwd;

  t.group('Directory Path manipulation testing', () {
    t.test('absolute', () {
      TestZone().run(() {
        var paths = setup();
        var cwd = pwd;
        t.expect(absolute(paths.pathTestDir),
            t.equals(join(cwd, paths.pathTestDir)));
      });
    });

    t.test('parent', () {
      TestZone().run(() {
        var paths = setup();
        t.expect(
            dirname(paths.pathTestDir), t.equals(join(TEST_ROOT, TEST_DIR)));
      });
    });

    t.test('extension', () {
      TestZone().run(() {
        var paths = setup();
        t.expect(extension(join(paths.pathTestDir, paths.testFile)),
            t.equals(paths.testExtension));
      });
    });

    t.test('basename', () {
      TestZone().run(() {
        var paths = setup();
        t.expect(basename(join(paths.pathTestDir, paths.testFile)),
            t.equals(paths.testFile));
      });
    });

    t.test('PWD', () {
      TestZone().run(() {
        var paths = setup();
        t.expect(pwd, t.startsWith(paths.home));
      });
    });

    t.test('CD', () {
      TestZone().run(() {
        var testdir = pwd;
        print('mfs cwd: ${pwd}');
        createDir('cd_test', recursive: true);
        cd('cd_test');
        t.expect(pwd, t.equals(absolute(join(testdir, 'cd_test'))));
        cd('..');
        t.expect(pwd, t.equals(absolute(cwd)));

        cd(cwd);
        t.expect(pwd, t.equals(cwd));
      });
    }, skip: false);

    t.test('Push/Pop', () {
      TestZone().run(() {
        var paths = setup();
        TestZone().run(() {
          var start = pwd;
          createDir(paths.pathTestDir, recursive: true);

          var expectedPath = absolute(paths.pathTestDir);
          push(paths.pathTestDir);
          t.expect(pwd, t.equals(expectedPath));

          pop();
          t.expect(pwd, t.equals(start));

          deleteDir(paths.pathTestDir, recursive: true);
        });
      });
    }, skip: false);

    t.test('Too many pops', () {
      TestZone().run(() {
        t.expect(() => pop(), t.throwsA(t.TypeMatcher<PopException>()));
      });
    }, skip: false);
    //});
  });
}

class Paths {
  String home;
  String pathTestDir;
  String testExtension;
  String testBaseName;
  String testFile;

  Paths() {
    home = env('HOME');
    pathTestDir = join(TEST_ROOT, TEST_DIR, 'pathTestDir');
    testExtension = '.jpg';
    testBaseName = 'fred';
    testFile = '$testBaseName$testExtension';
  }
}

Paths setup() {
  return Paths();
}
