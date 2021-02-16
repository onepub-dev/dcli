@Timeout(Duration(minutes: 10))
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  t.test('Try everything', () {
    TestFileSystem().withinZone((fs) {
      const shellPath = 'shell';
      final mainPath = join(shellPath, 'main');
      try {
        print('PWD: $pwd');

        if (!exists(mainPath)) {
          createDir(mainPath, recursive: true);
        }

        createDir(join(mainPath, 'fred', 'tom'), recursive: true);
        deleteDir(join(mainPath, 'fred', 'tom'));

        touch(join(mainPath, 'good.jpg'), create: true);

        final subdirPath = join(mainPath, 'subdir');

        if (!exists(subdirPath)) {
          createDir(subdirPath, recursive: true);
        }
        touch(join(subdirPath, 'good.jpg'), create: true);

        echo('Find file matching *.jpg');

        for (final file in find(
          '*.jpg',
        ).toList()) {
          print('Found jpg: ${truepath(file)}');
        }
        echo('sleeping for 2 seconds');
        sleep(2);

        echo('All files');
        for (final file in fileList) {
          print(file);
        }

        move(join(subdirPath, 'good.jpg'), join(subdirPath, 'bad.jpg'));

        if (exists(join(subdirPath, 'bad.jpg'))) {
          print('bad.jpg exists');
        }

        delete(join(subdirPath, 'bad.jpg'));

        echo(pwd);
      } finally {
        print('In finally');
        deleteDir(shellPath);
        if (exists(mainPath)) {
          deleteDir(mainPath);
        }
      }
    });
  });
}
