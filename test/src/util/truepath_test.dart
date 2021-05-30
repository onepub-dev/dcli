import 'package:dcli/src/util/truepath.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('truepath ...', () async {
    expect(truepath(join(rootPath, 'tmp')), equals(absolute(rootPath, 'tmp')));
    expect(truepath(join(rootPath, 'tmp', '..', 'tmp')),
        equals(absolute(rootPath, 'tmp')));
    expect(truepath(join(rootPath, 'tmp', '..', 'tmp', '.')),
        equals(absolute(rootPath, 'tmp')));
    expect(truepath(join(rootPath, 'tmp', '.')),
        equals(absolute(rootPath, 'tmp')));
    expect(
        truepath(join(rootPath, 'Local')), equals(absolute(rootPath, 'Local')));
  });
}
