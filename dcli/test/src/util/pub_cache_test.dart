/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_test/src/test_scope.dart';
import 'package:path/path.dart' hide equals;
import 'package:pub_semver/pub_semver.dart';
import 'package:scope/scope.dart';
import 'package:test/test.dart';

void main() {
  test(
    'PubCache',
    () {
      if (Settings().isWindows) {
        expect(
          PubCache().pathToBin,
          equals(join(env['LocalAppData']!, 'Pub', 'Cache', 'bin')),
        );
      } else {
        expect(
          PubCache().pathToBin,
          equals(join(env['HOME']!, '.pub-cache', 'bin')),
        );
      }
    },
    skip: false,
  );

  test(
    'PubCache - from ENV',
    () async {
      await withTestScope((outerTempDir) async {
        await core.withEnvironmentAsync(() async {
          /// create a pub-cache using the test scope's HOME
          final scope = Scope()..value(PubCache.scopeKey, PubCache.forScope());
          await scope.run(() async {
            if (Settings().isWindows) {
              expect(
                  PubCache().pathToBin,
                  equals(
                      join(outerTempDir, 'test_cache', '.pub-cache', 'bin')));
            } else {
              expect(
                PubCache().pathToBin,
                equals(join(outerTempDir, 'test_cache', '.pub-cache', 'bin')),
              );
            }
          });
        }, environment: {
          'PUB_CACHE': join(outerTempDir, 'test_cache', '.pub-cache')
        });
      });
    },
    skip: false,
  );

  test('PubCache - primaryVersion', () async {
    await withTestScope((tempDir) async {
      await core.withEnvironmentAsync(() async {
        /// create a pub-cache using the test scope's HOME
        final scope = Scope()..value(PubCache.scopeKey, PubCache.forScope());
        await scope.run(() async {
          final pubCache = PubCache();
          createDir(pubCache.pathToDartLang, recursive: true);
          createDir(join(pubCache.pathToDartLang, 'dcli-1.0.0-beta.1'));

          var primary = PubCache().findPrimaryVersion('dcli');
          expect(primary, isNotNull);
          expect(primary, equals(Version.parse('1.0.0-beta.1')));
          expect(primary!.isPreRelease, isTrue);

          createDir(join(pubCache.pathToDartLang, 'dcli-1.0.0'));

          primary = PubCache().findPrimaryVersion('dcli');
          expect(primary, isNotNull);
          expect(primary, equals(Version.parse('1.0.0')));
          expect(primary!.isPreRelease, isFalse);

          createDir(join(pubCache.pathToDartLang, 'dcli-1.0.1'));
          primary = PubCache().findPrimaryVersion('dcli');
          expect(primary, isNotNull);
          expect(primary, equals(Version.parse('1.0.1')));
          expect(primary!.isPreRelease, isFalse);

          createDir(join(pubCache.pathToDartLang, 'dcli-2.0.0'));
          createDir(join(pubCache.pathToDartLang, 'dcli-2.0.0-beta.1'));
          primary = PubCache().findPrimaryVersion('dcli');

          expect(primary, equals(Version.parse('2.0.0')));
          expect(primary!.isPreRelease, isFalse);
        });
      }, environment: {'PUB_CACHE': join(tempDir, '.pub-cache')});
    });
  });

  test('PubCache - findVersion', () async {
    await withTestScope((tempDir) async {
      await core.withEnvironmentAsync(() async {
        /// create a pub-cache using the test scope's HOME
        final scope = Scope()..value(PubCache.scopeKey, PubCache.forScope());
        await scope.run(() async {
          final pubCache = PubCache();
          createDir(pubCache.pathToDartLang, recursive: true);

          /// missing version
          var pathToVersion = PubCache().findVersion('dcli', '1.0.0');
          expect(pathToVersion == null, isTrue);

          // simple version
          var version = '1.0.0';
          createDir(join(pubCache.pathToDartLang, 'dcli-$version'));
          pathToVersion = PubCache().findVersion('dcli', version);
          expect(pathToVersion, isNotNull);
          expect(basename(pathToVersion!), equals('dcli-$version'));

          /// more than one version on path
          version = '2.0.0';
          createDir(join(pubCache.pathToDartLang, 'dcli-$version'));
          pathToVersion = PubCache().findVersion('dcli', version);
          expect(pathToVersion, isNotNull);
          expect(basename(pathToVersion!), equals('dcli-$version'));

          // beta version
          version = '1.0.0-beta.1';
          createDir(join(pubCache.pathToDartLang, 'dcli-$version'));
          pathToVersion = PubCache().findVersion('dcli', version);
          expect(pathToVersion, isNotNull);
          expect(basename(pathToVersion!), equals('dcli-$version'));
        });
      }, environment: {'PUB_CACHE': join(tempDir, '.pub-cache')});
    });
  });

  test('isRunning from Source', () {
    if (PubCache().isGloballyActivated('general')) {
      PubCache().globalDeactivate('general');
    }
    expect(PubCache().isGloballyActivatedFromSource('general'), isFalse);
    PubCache().globalActivateFromSource(
        join('..', 'dcli_unit_tester', 'test', 'test_script', 'general'));
    expect(PubCache().isGloballyActivatedFromSource('general'), isTrue);

    /// cleanup
    PubCache().globalDeactivate('general');
  });
}
