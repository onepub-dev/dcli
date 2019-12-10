@Timeout(Duration(seconds: 600))

import 'dart:io';

import 'package:dshell/script/entry_point.dart';
import 'package:dshell/settings.dart';
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

String script = "test/test_scripts/hello_world.dart";

String cwd = Directory.current.path;

String scriptDir = p.join(cwd, script);
String scriptPath = p.dirname(scriptDir);
String scriptName = p.basenameWithoutExtension(scriptDir);
String projectPath = p.join(
    Settings().cachePath, scriptPath.substring(1), scriptName + ".project");

void main() {
  group("Show Help", () {
    test('Help', () {
      EntryPoint().process(["help"]);
    });
  });
}
