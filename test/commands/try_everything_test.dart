import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import '../util/test_file_system.dart';

void main() {
  TestFileSystem();

  Settings().debug_on = true;

  t.test('Try everything', () {
    TestFileSystem().withinZone((fs) {
      var shellPath = 'shell';
      try {
        print('PWD: ${pwd}');

        var mainPath = join(shellPath, 'main');
        if (!exists(mainPath)) {
          createDir(mainPath, recursive: true);
        }

        createDir(join(mainPath, 'fred', 'tom'), recursive: true);
        deleteDir(join(mainPath, 'fred', 'tom'));

        touch(join(mainPath, 'good.jpg'), create: true);

        var subdirPath = join(mainPath, 'subdir');

        createDir(subdirPath, recursive: true);
        touch(join(subdirPath, 'good.jpg'), create: true);

        echo('Find file matching *.jpg');

        for (var file in find(
          '*.jpg',
        ).toList()) {
          print('Found jpg: ${absolute(file)}');
        }
        echo('sleeping for 2 seconds');
        sleep(2);

        echo('All files');
        for (var file in fileList) {
          print(file);
        }

        move(join(subdirPath, 'good.jpg'), join(subdirPath, 'bad.jpg'));

        if (exists(join(subdirPath, 'bad.jpg'))) {
          print('bad.jpg exists');
        }

        delete(join(subdirPath, 'bad.jpg'), ask: false);

        echo(pwd);
      } finally {
        print('In finally');
        deleteDir(shellPath);
      }
    });
  });
}

// File x;
// x << 'Append some text';
// x < 'Overright file';

// sh.echo('hi') >> x;

// file |

// var filename = read(prompt: 'Filename');
// echo('read $filename');

//cmd('git commit') | cmd('echo');

// var file = open(filename);
// while (file.isNotEmpty())
// {
//   print (file.read);
// }

// Cmd cmd(String cmd) {
//   return Cmd(cmd);
// }

// class Cmd
// {
//   String cmd;
//   Cmd(this.cmd);
//   Pipe operator | (Cmd cmd) {};
// }
// class Pipe
// {
//   Stream<String> stream = Stream();
//   void operator >> (File file)
//   {
//     whilst (this.isNotEmpty()){
//     file.write(this.read);
//     }
//   }
//   String get read => null;
// }
