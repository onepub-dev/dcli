@Timeout(Duration(seconds: 600))

import 'dart:io';

import 'package:dshell/functions/delete_dir.dart';
import 'package:dshell/functions/env.dart';
import 'package:dshell/functions/is.dart';
import 'package:dshell/script/entry_point.dart';
import 'package:dshell/settings.dart';
import 'package:dshell/util/dshell_exception.dart';
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

String script = "test/test_scripts/hello_world.dart";

String cwd = Directory.current.path;

String scriptDir = p.join(cwd, script);
String scriptPath = p.dirname(scriptDir);
String scriptName = p.basenameWithoutExtension(scriptDir);
String projectPath = p.join(
    Settings().cachePath, scriptPath.substring(1), scriptName + ".project");

String home;

void main() {
  group("Install DShell", () {
    setup();

    test('Install with success', () {
      try {
        EntryPoint().process(["install"]);
      } on DShellException catch (e) {
        print(e);
      }

      checkInstallStructure();
    });
    test('Install with error', () {
      try {
        setup();
        EntryPoint().process(["install", "a"]);
      } on DShellException catch (e) {
        print(e);
      }

      expect(exists("$home/.dshell"), equals(false));
    });

    test('With Lib', () {});
  });
}

void setup() {
  home = env("HOME");
  if (exists("$home/.dshell")) {
    deleteDir("$home/.dshell", recursive: true);
  }
}

void checkInstallStructure() {
  expect(exists("$home/.dshell"), equals(true));

  expect(exists("$home/.dshell/cache"), equals(true));

  expect(exists("$home/.dshell/templates"), equals(true));

  expect(exists("$home/.dshell/dependancies.yaml"), equals(true));
}
