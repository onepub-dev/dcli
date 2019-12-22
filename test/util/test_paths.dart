import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:path/path.dart';

class TestPaths {
  String home;
  String scriptDir;
  String scriptPath;
  String scriptName;
  String projectPath;

  TestPaths(String relativeScriptPath) {
    var cwd = Directory.current.path;
    home = env('HOME');
    scriptDir = join(cwd, relativeScriptPath);
    scriptPath = dirname(scriptDir);
    scriptName = basenameWithoutExtension(scriptDir);
    projectPath = join(
        Settings().cachePath, scriptPath.substring(1), scriptName + '.project');
  }
}
