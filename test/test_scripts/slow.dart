import "package:dshell/dshell.dart";

void main() {
  for (int i = 0; i < 1000; i++) {
    print("hello $i");
    sleep(1);
  }
}
