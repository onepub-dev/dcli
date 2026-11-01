import 'dart:io';
import 'dart:isolate';

import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart' show chmod;
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

  test('installs a standalone executable with public execute permission', () {
    final temp = Directory.systemTemp.createTempSync('dcli-install-file-');
    try {
      final source = File(join(temp.path, 'build', 'tool'))
        ..createSync(recursive: true)
        ..writeAsStringSync('compiled tool');
      final destinationDirectory = join(temp.path, 'system-bin');
      final installed = installCompiledExecutable(
        CompiledExecutable(source.path),
        overwrite: false,
        destinationDirectory: destinationDirectory,
      );

      expect(File(installed.pathToExe).readAsStringSync(), 'compiled tool');
      expect(source.existsSync(), isTrue);
      if (!Platform.isWindows) {
        expect(File(installed.pathToExe).statSync().mode & 0x1ff, 0x1ed);
      }
    } finally {
      temp.deleteSync(recursive: true);
    }
  });

  test('replaces a bundled executable and removes obsolete assets', () {
    final temp = Directory.systemTemp.createTempSync('dcli-install-bundle-');
    try {
      final destinationDirectory = join(temp.path, 'system-bin');

      CompiledExecutable build(String version, String asset) {
        final source = File(join(temp.path, version, 'tool'))
          ..createSync(recursive: true)
          ..writeAsStringSync(version);
        final bundle = CompiledExecutable.bundlePath(source.path);
        final library = File(join(bundle, 'lib', asset))
          ..createSync(recursive: true)
          ..writeAsStringSync(asset);
        if (!Platform.isWindows) {
          chmod(library.path, permission: '700');
        }
        return CompiledExecutable(source.path, hasBundle: true);
      }

      final first = installCompiledExecutable(
        build('first', 'old.so'),
        overwrite: false,
        destinationDirectory: destinationDirectory,
      );
      final second = installCompiledExecutable(
        build('second', 'new.so'),
        overwrite: true,
        destinationDirectory: destinationDirectory,
      );

      expect(first.pathToExe, second.pathToExe);
      expect(File(second.pathToExe).readAsStringSync(), 'second');
      expect(File(join(second.pathToBundle!, 'lib', 'old.so')).existsSync(),
          isFalse);
      final installedLibrary = File(
        join(second.pathToBundle!, 'lib', 'new.so'),
      );
      expect(installedLibrary.readAsStringSync(), 'new.so');
      if (!Platform.isWindows) {
        expect(installedLibrary.statSync().mode & 0x1ff, 0x164);
      }
    } finally {
      temp.deleteSync(recursive: true);
    }
  });
}
