/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart';
import 'package:scope/scope.dart';

final commonTestPubCache = join(rootPath, 'tmp', '.dcli', '.pub-cache');

/// Key containing the path to the original HOME.
/// final originalHomeKey = ScopeKey<String>();

/// Sets up a test scope providing unique
/// Environment
/// Platform OS
/// Settings initialised with the provided environment and OS
/// PubCache initialised with the Environment.
Future<void> withTestScope(Future<void> Function(String testDir) callback,
    {Map<String, String> environment = const <String, String>{},
    String? pathToTestDir,
    core.DCliPlatformOS? overridePlatformOS}) async {
  // final originalHome = HOME;

  await UnitTestController.withUnitTest(() async {
    await core.withTempDir((testDir) async {
      await core.withEnvironment(() async {
        final scope = Scope()
          // ignore: invalid_use_of_visible_for_testing_member
          ..value(installFromSourceKey, true)
          ..value(
              core.DCliPlatform.scopeKey,
              core.DCliPlatform.forScope(
                  overriddenPlatform: overridePlatformOS));

        await scope.run(() async {
          final innerScope = Scope()
            ..value(Settings.scopeKey, Settings.forScope())
            ..value(PubCache.scopeKey, PubCache.forScope());
          // ..value(originalHomeKey, originalHome)
          await innerScope.run(() async {
            await callback(testDir);
          });
        });
      }, environment: {
        'HOME': testDir,

        /// add our pub-cache to the front of the path so dcli is
        /// run from there.
        'PATH': [join(commonTestPubCache, 'bin'), ...PATH]
            .join(Env().delimiterForPATH),

        /// we need to force the pub cache to use a shared test cache
        /// as the above change to HOME will cause the pub-cache to
        /// be moved to the tests test file system causing it to be
        /// re-downloaded for each test run.
        'PUB_CACHE': commonTestPubCache
      });
    }, pathToTempDir: pathToTestDir);
  });
}
