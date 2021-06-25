import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('replace ...', () async {
    withTempFile((temp) {
      temp
        ..write('abc123')
        ..append('def246');
      replace(temp, RegExp('[a-z]*'), 'xyz');

      expect(read(temp).toParagraph(), '''
xyz123
xyz246''');

      temp
        ..write('abc123')
        ..append('def246');
      replace(temp, 'abc', 'xyz');

      expect(read(temp).toParagraph(), '''
xyz123
def246''');
    });
  });
}
