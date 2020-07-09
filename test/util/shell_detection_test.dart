import 'dart:io';

@Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/shell/cmd_shell.dart';
import 'package:test/test.dart';

void main() {
  test('Detect Shell', () {
    //TestFileSystem().withinZone((fs) {
    var shell = ShellDetection().identifyShell();
    print(shell.name);

    String expected;
    if (Platform.isWindows)
    {
      expected = CmdShell.shellName;
    }
    else if (Platform.isLinux)
    {
      expected = BashShell.shellName;
    }
     else if (Platform.isMacOS)
    {
      expected = ZshShell.shellName;
    }

    expect(shell.name, equals(expected));
  });
//  }, skip: false);
}
