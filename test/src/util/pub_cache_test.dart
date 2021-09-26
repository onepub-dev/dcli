@Timeout(Duration(minutes: 5))
import 'dart:io';
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/util/pub_cache.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  test(
    'PubCache',
    () {
      PubCache.reset();
      Env.reset();

      /// we don't necessarily have a HOME env in the test environment.
      env['HOME'] = join('/home');
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
    () {
      PubCache.reset();
      Env.reset();

      /// we don't necessarily have a HOME env in the test environment.
      env['HOME'] = join('/home');
      env['PUB_CACHE'] = join(Platform.pathSeparator, 'test_cache');
      if (Settings().isWindows) {
        expect(PubCache().pathToBin, equals(join(r'C:\test_cache', 'bin')));
      } else {
        expect(
          PubCache().pathToBin,
          equals(join(Platform.pathSeparator, 'test_cache', 'bin')),
        );
      }
    },
    skip: false,
  );

  test('PubCache - primaryVersion', () {
    withTempDir((tempDir) {
      PubCache.reset();
      Env.reset();

      /// we don't necessarily have a HOME env in the test environment.
      env['HOME'] = createDir(join(tempDir, 'home'));
      env['PUB_CACHE'] = createDir(join(tempDir, 'test_cache'));

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
  });
}
