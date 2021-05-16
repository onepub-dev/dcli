@t.Timeout(Duration(seconds: 600))
import 'package:test/test.dart' as t;


void main() {
  /// waiting of dart fixed to Uri.base
  t.test('Test Zone CWD', () {
    // Test for dart bug
    // https://github.com/dart-lang/sdk/issues/39796
    t.expect(Uri.base, t.equals('.'));
  }, skip: true);
}
