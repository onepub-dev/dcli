import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/commands/install.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:di_zone2/di_zone2.dart';

late final commonTestPubCache = join(rootPath, 'tmp', '.dcli', '.pub-cache');

/// Key containing the path to the original HOME.
/// final originalHomeKey = ScopeKey<String>();

/// Sets up a test scope providing unique
/// Environment
/// Platform OS
/// Settings initialised with the provided environment and OS
/// PubCache initialised with the Environment.
void withTestScope(void Function(String testDir) callback,
    {Map<String, String> environment = const <String, String>{},
    String? pathToTestDir,
    core.DCliPlatformOS? overridePlatformOS}) {
  // final originalHome = HOME;

  withTempDir((testDir) {
    withEnvironment(() {
      Scope()
        ..value(InstallCommand.activateFromSourceKey, true)
        ..value(core.DCliPlatform.scopeKey,
            core.DCliPlatform.forScope(overriddenPlatform: overridePlatformOS))
        ..run(() {
          Scope()
            ..value(Settings.scopeKey, Settings.forScope())
            ..value(PubCache.scopeKey, PubCache.forScope())
            // ..value(originalHomeKey, originalHome)
            ..run(() {
              callback(testDir);
            });
        });
    }, environment: {
      'HOME': testDir,

      /// add our pub-cache to the front of the path so dcli is run from there.
      'PATH': [join(commonTestPubCache, 'bin'), ...PATH]
          .join(Env().delimiterForPATH),

      /// we need to force the pub cache to use a shared test cache
      /// as the above change to HOME will cause the pub-cache to
      /// be moved to the tests test file system causing it to be
      /// re-downloaded for each test run.
      'PUB_CACHE': commonTestPubCache
    });
  }, pathToTempDir: pathToTestDir);
}
