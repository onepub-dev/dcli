@Timeout(Duration(seconds: 600))
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/functions/env.dart';
import 'package:dcli/src/util/dcli_paths.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

/// TestPaths sets up an isolated area for unit tests to run without
/// interfering with your normal dcli install.
///
/// To do this it modifies the folling environment variables:
///
/// HOME = /tmp/dcli/home
/// PUB_CACHE = /tmp/dcli/.pub_cache
///
/// The dcli cache is therefore located at:
///
/// /tmp/dcli/cache
///
/// As the unit test suite creates an isolated .pub-cache it will be empty.
/// As such when the unit tests start dcli is not actually installed in the
/// active .pub-cache.
///
///
/// The result is that dcli is neither available in .pub-cache 
/// nor installed into
/// .dcli.
///
/// This is not a problem for running most unit tests as the are using the
/// primary .pub-cache. It is however a problem if you attempt to spawn
/// a dcli instance on the cli.
///
/// The first time TestPaths is called it will create the necessary paths
/// and install dcli.
///
/// To ensure that the install happens at the start of each test
///  run (and then only once)
/// we store the test runs PID into /tmp/dcli/PID.
/// If the PID changes we know we need to recreate and reinstall everything.
///
///

class TestPaths {
  static final TestPaths _self = TestPaths._internal();

  static late String testRoot;

  String? home;
  //String scriptDir;
  String? testScriptPath;
  String? scriptName;
  //String projectPath;
  String? testRootForPid;

  factory TestPaths() {
    return _self;
  }

  TestPaths._internal() {
    testRoot = join(rootPath, 'tmp', 'dcli');
    // each unit test process has its own directory.

    testRootForPid = join(testRoot, '$pid');

    print('unit test for $pid running from $pid');

    // redirecct HOME to /tmp/dcli/home
    final home = truepath(testRoot, 'home');
    env['HOME'] = home;

    // // create test .pub-cache dir
    // var pubCachePath = truepath(TEST_ROOT, PubCache().cacheDir);
    // env['PUB_CACHE'] = pubCachePath;

    // add the unit test dcli/bin path to the front
    // of the PATH so that our test version of dcli tooling
    // will run when we spawn a dcli process.
    final path = PATH;
    path.insert(0, Settings().pathToDCliBin);

    // .pub-cache so we run the test version of dcli.
    // path.insert(0, pubCachePath);

    env['PATH'] = path.join(Env().delimiterForPATH);

    final dcliPath = Settings().pathToDCli;
    if (!dcliPath.startsWith(join(rootPath, 'tmp')) ||
        !HOME.startsWith(join(rootPath, 'tmp')))
    //  ||        !env['PUB_CACHE'].startsWith('/tmp'))
    {
      printerr('''
Something went wrong, the dcli path or HOME for unit tests is NOT pointing to /tmp. 
          dcli's path is pointing at $dcliPath
          HOME is pointing at $HOME
          PUB_CACHE is pointing at ${env['PUB_CACHE']}
          ''');
      printerr('We have shutdown the unit tests to protect your filesystem.');
      exit(1);
    }

    // create test home dir
    recreateDir(home);

    recreateDir(Settings().pathToDCli);

    recreateDir(Settings().pathToDCliBin);

    // the cache is normally in .dcliPath
    // but just in case its not we create it directly
    recreateDir(Settings().pathToDCliCache);

    // recreateDir(pubCachePath);

    testScriptPath = truepath(testRoot, 'scripts');

    installDCli();
  }

  void recreateDir(String path) {
    // if (exists(path)) {
    //   deleteDir(path, recursive: true);
    // }
    if (!exists(path)) {
      createDir(path, recursive: true);
    }
  }

  void installDCli() {
    'dart pub global activate --source path .'.run;

    which('dcli').paths.forEach(print);

    print('dcli path: ${Settings().pathToDCli}');

    if (!exists(Settings().pathToDCli)) {
      createDir(Settings().pathToDCli);

      '${DCliPaths().dcliName} install'.run;
    }
  }
}
