import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/util/pub_cache.dart';
import 'package:path/path.dart';

class TestPaths {
  static final TestPaths _self = TestPaths._internal();

  static const String TEST_ROOT = '/tmp/dshell';
  static const String TEST_LINES_FILE = 'lines.txt';

  String home;
  //String scriptDir;
  String scriptPath;
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

    if (exists(home)) {
      deleteDir(home, recursive: true);
    }
    createDir(HOME, recursive: true);
    var pubCachePath = truepath(TEST_ROOT, PubCache().cacheDir);
    setEnv('PUB_CACHE', pubCachePath);
    if (exists(pubCachePath)) {
      deleteDir(pubCachePath, recursive: true);
    }
    createDir(pubCachePath, recursive: true);
    home = HOME;
    scriptPath = truepath(TEST_ROOT, 'scripts');
    //scriptDir = truepath(scriptPath, relativeScriptPath);
  }

  String projectPath(String scriptName) => join(Settings().dshellCachePath,
      scriptPath.substring(1), scriptName + '.project');
}
