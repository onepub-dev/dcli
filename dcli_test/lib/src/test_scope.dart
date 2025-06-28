/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_common/dcli_common.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';
import 'package:scope/scope.dart';

final commonTestPubCache = join(rootPath, 'tmp', '.dcli', '.pub-cache');

/// Sets up a test scope providing a unique
/// Environment
/// Platform OS
/// Settings initialised with the provided environment and OS
/// PubCache initialised with the Environment.
Future<void> withTestScope(Future<void> Function(String testDir) callback,
    {Map<String, String> environment = const <String, String>{},
    String? pathToTestDir,
    core.DCliPlatformOS? overridePlatformOS}) async {

  await UnitTestController.withUnitTest(() async {
    await core.withTempDirAsync((testDir) async {
      await core.withEnvironmentAsync(() async {
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
