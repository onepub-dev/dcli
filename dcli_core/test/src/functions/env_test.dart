import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('env ...', () async {
    expect(Env().exists('PATH') == true, isTrue);
    expect(Env().exists('FREDWASHERE') == true, isFalse);
    env['AAAA'] = null;
    expect(Env().exists('AAAA') == true, isFalse);
    env['AAAA'] = '';
    expect(Env().exists('AAAA') == true, isTrue);
  });
}
