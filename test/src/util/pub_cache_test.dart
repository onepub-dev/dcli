@Timeout(Duration(minutes: 5))
import 'dart:io';
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/util/pub_cache.dart';
import 'package:test/test.dart';

void main() {
  test('PubCache', () {
    PubCache.reset();
    Env.reset();

    /// we don't necessarily have a HOME env in the test environment.
    setEnv('HOME', join('/home'));
    if (Platform.isWindows) {
      expect(
          PubCache().binPath,
          equals(
              join(env('LocalAppData'), 'Pub', 'Cache', 'bin').toLowerCase()));
    } else {
      expect(
          PubCache().binPath, equals(join(env('HOME'), '.pub-cache', 'bin')));
    }
  }, skip: false);

  test('PubCache - from ENV', () {
    PubCache.reset();
    Env.reset();

    /// we don't necessarily have a HOME env in the test environment.
    setEnv('HOME', join('/home'));
    setEnv('PUB_CACHE', join(Platform.pathSeparator, 'test_cache'));
    if (Platform.isWindows) {
      expect(PubCache().binPath,
          equals(join(r'c:\test_cache', 'bin').toLowerCase()));
    } else {
      expect(PubCache().binPath,
          equals(join(Platform.pathSeparator, 'test_cache', 'bin')));
    }
  }, skip: false);
}
