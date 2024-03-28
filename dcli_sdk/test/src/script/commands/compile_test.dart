@Timeout(Duration(seconds: 600))
library;

import 'package:dcli_sdk/src/commands/compile.dart';
import 'package:test/test.dart';

void main() {
  test('compile package ', () async {
    CompileCommand().compilePackage('dcli_unit_tester');
  });
}
