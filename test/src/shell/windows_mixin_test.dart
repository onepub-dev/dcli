import 'package:dcli/dcli.dart';
import 'package:dcli/src/shell/power_shell.dart';
import 'package:test/test.dart';

void main() {
  test('windows mixin ...', () async {
    WindowsMixin.appendToPath(['bb']);
  });
}
