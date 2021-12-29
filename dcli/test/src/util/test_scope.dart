import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:di_zone2/di_zone2.dart';

/// Key containing the path to the original HOME.
final originalHomeKey = ScopeKey<String>();

/// Sets up a test scope providing unique
/// Environment
/// Platform OS
/// Settings initialised with the provided environment and OS
/// PubCache initialised with the Environment.
void withTestScope(void Function(String testDir) callback,
    {Map<String, String> environment = const <String, String>{},
    String? pathToTestDir,
    core.DCliPlatformOS? overridePlatformOS}) {
  final originalHome = HOME;

  withTempDir((testDir) {
    withEnvironment(() {
      Scope()
        ..value(core.DCliPlatform.scopeKey,
            core.DCliPlatform.forScope(overriddenPlatform: overridePlatformOS))
        ..run(() {
          Scope()
            ..value(Settings.scopeKey, Settings.forScope())
            ..value(PubCache.scopeKey, PubCache.forScope())
            ..value(originalHomeKey, originalHome)
            ..run(() {
              callback(testDir);
            });
        });
    }, environment: {
      'HOME': testDir

      /// we need to force the pub cache back to the the users actual
      /// home as the above change to HOME will cause the pub-cache to
      /// be moved to the tests test file system causing it to be
      /// re-downloaded for each test run.
      ,
      'PUB_CACHE': PubCache().pathTo
    });
  }, pathToTempDir: pathToTestDir);
}
