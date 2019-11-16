import 'package:dshell/dshell.dart';

void main() {
  try {
    Settings().debug_on = true;

    // Print the current working directory
    print("PWD: ${pwd}");
    echo("PWD: ${pwd}");

    // Change to the directory 'main'
    cd("test");

    // Create a directory with any needed parents.
    makeDir("tools/images", createParent: true);

    // Push the current directory onto the stack
    // and change directory.
    push("tools/images");

    // create a file (its empty)
    touch("good.jpg", create: true);

    // update the last modified time on an existing file
    touch("good.jpg");

    // I think you know this one.
    echo("All files");

    // print out all files in the current directory.
    // fileList is a DShell property.
    for (var file in fileList) {
      print(file);
    }

    // take a nap for a couple of seconds.
    sleep(2);

    echo("Find file matching *.jpg");
    // Find all files that end with .jpg
    // in the current directory and any subdirectories
    for (var file in find("*.jpg")) {
      print(file);
    }

    // Move/rename a file
    move("good.jpg", "bad.jpg");

    // check if a file exists.
    if (exists("bad.jpg")) {
      print("bad.jpg exists");
    }

    // Delete a file asking the user first.
    delete("bad.jpg", ask: false);

    // return to the directory we were in
    // before we called push above.
    pop();

    // Print out our current working directory.
    echo(pwd);

    pop();
    push("..");

    // execute grep and print each matching line
    'grep version pubspec.yaml'.forEach((line) => print(line));

    // lets do some pipeing.
    ('tail /var/log/syslog' | 'head -n 5' | 'tail -n 2')
        .forEach((line) => print(line));
    pop();
  } catch (e) {
    print("An error occured: ${e.toString()}");
    e.printStackTrace();
  }
}
