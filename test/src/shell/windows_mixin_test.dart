import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('windows mixin ...', () async {
    WindowsMixin.appendToPath('bb');
  });
}
