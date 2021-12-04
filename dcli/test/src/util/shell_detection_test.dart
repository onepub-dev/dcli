@Timeout(Duration(minutes: 5))
import 'dart:io';
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/posix.dart';
import 'package:dcli/src/shell/cmd_shell.dart';
import 'package:test/test.dart';

void main() {
  test('Detect Shell', () {
    final shell = Shell.current;
    print(shell.name);

    String? expected;
    if (Settings().isWindows) {
      expected = CmdShell.shellName;
    } else if (Platform.isLinux) {
      expected = BashShell.shellName;
    } else if (Platform.isMacOS) {
      expected = ZshShell.shellName;
    }

    /// This can fail if you run from the vscode  terminal rather than a
    /// standard terminal  as under a vscode terminal it will return the
    ///  sh shell on linux rather than bash.
    expect(shell.name, equals(expected));
  });
}
