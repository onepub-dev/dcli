import 'dart:io';
import 'dart:isolate';

import 'package:dcli/dcli.dart';
import 'package:dcli_sdk/src/commands/system_install.dart';
import 'package:path/path.dart';
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

  test('privileged installer compiles as a native executable', () async {
    final packageUri = await Isolate.resolvePackageUri(
      Uri.parse('package:dcli_sdk/dcli_sdk.dart'),
    );
    final packageRoot = dirname(dirname(packageUri!.toFilePath()));
    final temp = Directory.systemTemp.createTempSync('dcli-system-test-');
    try {
      final helper = DartSdk().runDartCompiler(
        DartScript.fromFile(
          join(packageRoot, 'bin', 'dcli_system_install.dart'),
        ),
        pathToExe: join(temp.path, 'dcli_system_install'),
        workingDirectory: packageRoot,
      );
      expect(File(helper.pathToExe).existsSync(), isTrue);
    } finally {
      temp.deleteSync(recursive: true);
    }
  });
}
