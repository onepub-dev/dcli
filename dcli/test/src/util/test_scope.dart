import 'package:dcli/dcli.dart';
import 'package:di_zone2/di_zone2.dart';

void withTestScope(void Function(String testDir) callback,
    {Map<String, String> environment = const <String, String>{},
    String? pathToTestDir}) {
  withTempDir((testDir) {
    withEnvironment(() {
      Scope()
        ..value(Settings.scopeKey, Settings.forScope())
        ..value(PubCache.scopeKey, PubCache.forScope())
        ..run(() {
          callback(testDir);
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
