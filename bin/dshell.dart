import 'package:dshell/script/entry_point.dart';

void main(List<String> arguments) {
  DShell().run(arguments);
}

class DShell {
  String _appName = "dshell";
  String _version = "1.0.7";

  void run(List<String> arguments) {
    EntryPoint().process(_appName, _version, arguments);
  }
}
