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
    env['HOME'] = join('/home');
    if (Settings().isWindows) {
      expect(PubCache().pathToBin,
          equals(join(env['LocalAppData']!, 'Pub', 'Cache', 'bin')));
    } else {
      expect(PubCache().pathToBin,
          equals(join(env['HOME']!, '.pub-cache', 'bin')));
    }
  }, skip: false);

  test('PubCache - from ENV', () {
    PubCache.reset();
    Env.reset();

    /// we don't necessarily have a HOME env in the test environment.
    env['HOME'] = join('/home');
    env['PUB_CACHE'] = join(Platform.pathSeparator, 'test_cache');
    if (Settings().isWindows) {
      expect(PubCache().pathToBin, equals(join(r'C:\test_cache', 'bin')));
    } else {
      expect(PubCache().pathToBin,
          equals(join(Platform.pathSeparator, 'test_cache', 'bin')));
    }
  }, skip: false);
}
