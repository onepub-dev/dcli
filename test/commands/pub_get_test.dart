@Timeout(Duration(seconds: 600))

import 'dart:io';

import 'package:dshell/script/dart_sdk.dart';
import 'package:dshell/script/pub_get.dart';
import 'package:dshell/script/script.dart';
import 'package:dshell/script/virtual_project.dart';
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
  group("Pub Get", () {
    test('Do it', () {
      Script script = Script.fromFile("test/test_scripts/hello_world.dart");
      VirtualProject project = VirtualProject(Settings().cachePath, script);
      DartSdk sdk = DartSdk();
      PubGet(sdk, project).run();
    });
  });
}
