import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

void main() {
  Settings().debug_on = true;

  test('Dev null', () {
    // mainly just check if devnull compiles as expected.
    'ls'.forEach(devNull, stderr: (line) => printerr(line));
  });
}
