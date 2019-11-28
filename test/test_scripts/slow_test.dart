/*
@pubspec.yaml
name: hello_world.dart
dependencies:
  dshell: ^1.0.0
  money2: ^1.0.0
*/


import "package:dshell/dshell.dart";

void main() {
  'bash /home/bsutton/git/dshell/test/test_scripts/slow.sh'.forEach((line) => print(line));
}
