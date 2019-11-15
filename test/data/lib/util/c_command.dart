import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:args/command_runner.dart';

import '../yaml_me.dart';

class CCommand extends Command<void> {
  Directory lib;

  void run() async {
    lib = Directory(p.join(Directory.current.path, 'lib'));
    p.relative("hi");
    YamlMe("pubspec.yaml");
  }

  @override
  String get description => "Ccommand";

  @override
  String get name => "CCommand";
}
