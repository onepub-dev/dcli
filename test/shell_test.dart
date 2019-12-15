import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';

import 'test_settings.dart';
import 'util/test_fs_zone.dart';

void main() {
  Settings().debug_on = true;

  t.test("Try everything", () {
    TestZone().run(() {
      createDir(TEST_ROOT, recursive: true);

      try {
        push(TEST_ROOT);
        // Settings().debug_on = true;

        print("PWD: ${pwd}");

        createDir("shell/main", recursive: true);
        push("shell");
        cd("main");

        createDir("fred/tom", recursive: true);
        deleteDir("fred/tom");

        touch("good.jpg", create: true);
        createDir("subdir", recursive: true);
        touch("subdir/goody.jpg", create: true);

        echo("Find file matching *.jpg");

        for (var file in find(
          "*.jpg",
        ).toList()) {
          print("Found jpg: $file");
        }
        echo("sleeping for 2 seconds");
        sleep(2);

        echo("All files");
        for (var file in fileList) {
          print(file);
        }

        move("good.jpg", "bad.jpg");

        if (exists("bad.jpg")) {
          print("bad.jpg exists");
        }

        delete("bad.jpg", ask: false);

        pop();
        echo(pwd);
      } finally {
        print("In finally");
        pop();
      }
    });
  });
}

// File x;
// x << "Append some text";
// x < "Overright file";

// sh.echo("hi") >> x;

// file |

// var filename = read(prompt: "Filename");
// echo("read $filename");

//cmd("git commit") | cmd("echo");

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
