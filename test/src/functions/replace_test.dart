import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('replace ...', () async {
    final temp = FileSync.tempFile()
      ..write('abc123')
      ..append('def246');
    replace(temp, RegExp('[a-z]*'), 'xyz');

    expect(read(temp).toList().join('\n'), '''
xyz123
xyz246''');

    temp
      ..write('abc123')
      ..append('def246');
    replace(temp, 'abc', 'xyz');

    expect(read(temp).toList().join('\n'), '''
xyz123
def246''');
  });
}
