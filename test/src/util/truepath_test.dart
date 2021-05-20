import 'package:dcli/src/util/truepath.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('truepath ...', () async {
    expect(truepath(join(rootPath, 'tmp')), equals(join(rootPath, 'tmp')));
    expect(truepath(join(rootPath, 'tmp', '..', 'tmp')),
        equals(join(rootPath, 'tmp')));
    expect(truepath(join(rootPath, 'tmp', '..', 'tmp', '.')),
        equals(join(rootPath, 'tmp')));
    expect(truepath(join(rootPath, 'tmp', '.')), equals(join(rootPath, 'tmp')));
    expect(truepath(join(rootPath, 'Local')), equals(join(rootPath, 'Local')));
  });
}
