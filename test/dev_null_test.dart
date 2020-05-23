@Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

void main() {
  test('Dev null', () {
    // mainly just check if devnull compiles as expected.
    'ls'.forEach(devNull, stderr: printerr);
  });
}
