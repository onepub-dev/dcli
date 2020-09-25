import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('which ...', () async {
    expect(which('ls').path, equals('/usr/bin/ls'));
    expect(which('ls').found, equals(true));
    expect(which('ls').notfound, equals(false));
    expect(which('ls').paths.length, equals(1));
  });
}
