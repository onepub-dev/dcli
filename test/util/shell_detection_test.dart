@Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('Detect Shell', () {
    //TestFileSystem().withinZone((fs) {
    var shell = ShellDetection().identifyShell();
    print(shell.name);
    expect(shell.name, equals(BashShell.shellName));
  });
//  }, skip: false);
}
