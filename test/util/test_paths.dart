import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/functions/env.dart';
import 'package:path/path.dart';

import '../test_settings.dart';

class TestPaths {
  String home;
  String scriptDir;
  String scriptPath;
  String scriptName;
  String projectPath;
  String testRoot;

  TestPaths(String relativeScriptPath) {
    var cwd = Directory.current.path;
    testRoot = TEST_ROOT;
    home = HOME;
    scriptDir = join(cwd, relativeScriptPath);
    scriptPath = dirname(scriptDir);
    scriptName = basenameWithoutExtension(scriptDir);
    projectPath = join(
        Settings().cachePath, scriptPath.substring(1), scriptName + '.project');
  }
}
