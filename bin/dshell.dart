import 'package:dshell/script/entry_point.dart';

void main(List<String> arguments) {
  DShell().run(arguments);
}

class DShell {
  void run(List<String> arguments) {
    EntryPoint().process(arguments);
  }
}
