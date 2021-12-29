import 'package:dcli/src/windows/process_helper.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:test/test.dart';

void main() {
  test(
    'process helper ...',
    () async {
      final processes = getWindowsProcesses();

      expect(processes.map((process) => process.name), contains('dart.exe'));
    },
    skip: !core.Settings().isWindows,
  );
}
