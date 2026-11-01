import 'package:dcli_sdk/src/commands/system_install.dart';
import 'package:test/test.dart';

void main() {
  test('system install destinations are machine-wide', () {
    expect(systemInstallDirectory(operatingSystem: 'linux'), '/usr/local/bin');
    expect(systemInstallDirectory(operatingSystem: 'macos'), '/usr/local/bin');
    expect(
      systemInstallDirectory(
        operatingSystem: 'windows',
        programFiles: r'D:\Programs',
      ),
      r'D:\Programs\DCli\bin',
    );
  });
}
