import 'package:dshell/dshell.dart';
// import 'package:dshell/util/string_extension.dart';

void main() {
  Settings().debug_on = true;

  // 'fred'.hi();

  print("PWD: ${pwd}");

  makeDir("test/data/shell/main", createParent: true);
  push("test/data/shell");
  cd("main");

  makeDir("fred/tom", createParent: true);

  touch("good.jpg");
  makeDir("subdir", createParent: true);
  touch("subdir/goody.jpg");

  echo("Find file matching *.jpg");
  for (var file in find(
    "*.jpg",
  )) {
    print(file);
  }

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

  // 'echo hi'.run;
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
