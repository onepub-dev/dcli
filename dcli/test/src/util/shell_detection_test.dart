import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/posix.dart';
import 'package:dcli/src/shell/cmd_shell.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:test/test.dart';

void main() {
  test('Detect Shell', () {
    final shell = Shell.current;
    print(shell.name);

    String? expected;
    if (Settings().isWindows) {
      expected = CmdShell.shellName;
    } else if (core.Settings().isLinux) {
      expected = BashShell.shellName;
    } else if (core.Settings().isMacOS) {
      expected = ZshShell.shellName;
    }

    /// This can fail if you run from the vscode  terminal rather than a
    /// standard terminal  as under a vscode terminal it will return the
    ///  sh shell on linux rather than bash.
    expect(shell.name, equals(expected));
  });
}
