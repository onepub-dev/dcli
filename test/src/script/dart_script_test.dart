import 'package:dcli/src/script/dart_script.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('dart script ...', () async {
    expect(DartScript.stripDartVersionSuffix('pub_release.dart-2.13.0'),
        equals('pub_release.dart'));

    expect(DartScript.stripDartVersionSuffix('pub_release.dart'),
        equals('pub_release.dart'));

    expect(
        DartScript.stripDartVersionSuffix(
            p.join('some', 'path', 'pub_release.dart-2.13.0')),
        equals(p.join('some', 'path', 'pub_release.dart')));

    expect(
        DartScript.stripDartVersionSuffix(
            p.join('some', 'path', 'pub_release.dart')),
        equals(p.join('some', 'path', 'pub_release.dart')));

    expect(DartScript.fromFile('dart_script_test.dart').scriptName,
        equals('dart_script_test.dart'));
  });
}
