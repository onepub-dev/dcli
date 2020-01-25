import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/script/virtual_project.dart';
import 'package:dshell/src/util/pub_cache.dart';
import 'package:path/path.dart';

class TestPaths {
  static final TestPaths _self = TestPaths._internal();

  static const String TEST_ROOT = '/tmp/dshell';
  static const String TEST_LINES_FILE = 'lines.txt';

  String home;
  //String scriptDir;
  String testScriptPath;
  String scriptName;
  //String projectPath;
  String testRoot;

  factory TestPaths() {
    return _self;
  }

  TestPaths._internal() {
    testRoot = TEST_ROOT;
    var home = truepath(TEST_ROOT, 'home');
    setEnv('HOME', home);

    // create test home dir
    recreateDir(home);

    recreateDir(Settings().dshellPath);

    // the cache is normally in .dshellPath
    // but just in case its not we create it directly
    recreateDir(Settings().dshellCachePath);

    // create test .pub-cache dir
    var pubCachePath = truepath(TEST_ROOT, PubCache().cacheDir);
    setEnv('PUB_CACHE', pubCachePath);
    recreateDir(pubCachePath);

    testScriptPath = truepath(TEST_ROOT, 'scripts');
  }

  String projectPath(String scriptName) {
    String projectPath;
    var projectScriptPath =
        join(dirname(scriptName), basenameWithoutExtension(scriptName));
    if (scriptName.startsWith(Platform.pathSeparator)) {
      projectPath = truepath(Settings().dshellCachePath,
          projectScriptPath.substring(1) + VirtualProject.PROJECT_DIR);
    } else {
      projectPath = truepath(
          Settings().dshellCachePath,
          testScriptPath.substring(1),
          projectScriptPath + VirtualProject.PROJECT_DIR);
    }
    return projectPath;
  }

  void recreateDir(String path) {
    if (exists(path)) {
      deleteDir(path, recursive: true);
    }
    createDir(path, recursive: true);
  }
}
