import 'dart:io';
import 'dart:isolate';

import 'package:dcli/dcli.dart';
import 'package:dcli/posix.dart' show chmod;
import 'package:path/path.dart';

import '../version/version.g.dart';

/// The location used for commands available to every user of this machine.
String systemInstallDirectory({String? operatingSystem, String? programFiles}) {
  switch (operatingSystem ?? Platform.operatingSystem) {
    case 'linux':
    case 'macos':
      return '/usr/local/bin';
    case 'windows':
      return windows.join(
        programFiles ??
            Platform.environment['ProgramFiles'] ??
            r'C:\Program Files',
        'DCli',
        'bin',
      );
    default:
      throw UnsupportedError(
        'System installation is not supported on this OS.',
      );
  }
}

/// Installs a compiled executable and its optional bundle with administrator
/// ownership. Compilation must happen before this privileged operation.
Future<CompiledExecutable> installForAllUsers(
  CompiledExecutable compiled, {
  required bool overwrite,
}) async {
  if (Platform.isWindows) {
    if (!Shell.current.isPrivilegedUser) {
      throw StateError('Run dcli from an Administrator terminal for --system.');
    }
    final installed = installCompiledExecutable(
      compiled,
      overwrite: overwrite,
      destinationDirectory: systemInstallDirectory(),
    );
    _addWindowsMachinePath(systemInstallDirectory());
    _removeCompiledOutput(compiled);
    return installed;
  }
  if (!Shell.current.isPrivilegedProcess) {
    return await _installWithSudo(compiled, overwrite: overwrite);
  }

  late CompiledExecutable installed;
  try {
    Shell.current.withPrivileges(() {
      installed = installCompiledExecutable(
        compiled,
        overwrite: overwrite,
        destinationDirectory: systemInstallDirectory(),
      );
    });
  } finally {
    Shell.current.releasePrivileges();
  }
  _removeCompiledOutput(compiled);
  return installed;
}

Future<CompiledExecutable> _installWithSudo(
  CompiledExecutable compiled, {
  required bool overwrite,
}) async {
  final packageUri = await Isolate.resolvePackageUri(
    Uri.parse('package:dcli_sdk/dcli_sdk.dart'),
  );
  final adjacentHelper = join(
    dirname(DartScript.self.pathToScript),
    'dcli_system_install.dart',
  );
  final packageRoot = File(adjacentHelper).existsSync()
      ? dirname(dirname(adjacentHelper))
      : packageUri == null
          ? PubCache().pathToPackage('dcli_sdk', packageVersion)
          : dirname(dirname(packageUri.toFilePath()));
  final packageConfig = join(packageRoot, '.dart_tool', 'package_config.json');
  final buildDirectory = File(packageConfig).existsSync()
      ? packageRoot
      : PubCache().pathToGlobalPackage('dcli_sdk');
  final helperScript = join(packageRoot, 'bin', 'dcli_system_install.dart');
  if (!File(helperScript).existsSync()) {
    throw StateError('Unable to find the system installation helper.');
  }

  final staging = Directory.systemTemp.createTempSync('dcli-system-helper-');
  try {
    final helper = DartSdk().runDartCompiler(
      DartScript.fromFile(helperScript),
      pathToExe: join(staging.path, 'dcli_system_install'),
      workingDirectory: buildDirectory,
    );
    final process = await Process.start('sudo', [
      helper.pathToExe,
      compiled.pathToExe,
      if (compiled.hasBundle) 'bundle' else 'single',
      if (compiled.isPacked) 'packed' else 'unpacked',
      if (overwrite) 'overwrite' else 'keep',
    ], mode: ProcessStartMode.inheritStdio);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw StateError('System installation failed (exit code $exitCode).');
    }
    return CompiledExecutable(
      join(systemInstallDirectory(), basename(compiled.pathToExe)),
      hasBundle: compiled.hasBundle,
      isPacked: compiled.isPacked,
    );
  } finally {
    staging.deleteSync(recursive: true);
  }
}

/// Copies an executable and its bundle into [destinationDirectory].
/// The caller must ensure that the directory is an authorised destination.
CompiledExecutable installCompiledExecutable(
  CompiledExecutable compiled, {
  required bool overwrite,
  required String destinationDirectory,
}) {
  final bin = Directory(destinationDirectory)..createSync(recursive: true);
  final destination = join(bin.path, basename(compiled.pathToExe));
  final staging = bin.createTempSync('.dcli-system-');
  try {
    final stagedPath = join(staging.path, basename(compiled.pathToExe));
    File(compiled.pathToExe).copySync(stagedPath);
    if (!Platform.isWindows) {
      chmod(stagedPath, permission: '755');
    }
    if (compiled.hasBundle) {
      final stagedBundle = CompiledExecutable.bundlePath(stagedPath);
      Directory(stagedBundle).createSync();
      copyTree(compiled.pathToBundle!, stagedBundle, includeHidden: true);
      if (!Platform.isWindows) {
        for (final entry in Directory(
          compiled.pathToBundle!,
        ).listSync(recursive: true, followLinks: false)) {
          if (entry is File) {
            final target = join(
              stagedBundle,
              relative(entry.path, from: compiled.pathToBundle),
            );
            _copyPublicPermission(entry.path, target);
          }
        }
      }
    }
    return CompiledExecutable(
      stagedPath,
      hasBundle: compiled.hasBundle,
      isPacked: compiled.isPacked,
    ).install(destination, overwrite: overwrite);
  } finally {
    staging.deleteSync(recursive: true);
  }
}

void _copyPublicPermission(String source, String destination) {
  // Readable by every user, executable only when the source was executable.
  // Never carry a user-writable mode into a system command's bundle.
  final mode = 0x124 | (File(source).statSync().mode & 0x49);
  chmod(destination, permission: mode.toRadixString(8).padLeft(3, '0'));
}

void _removeCompiledOutput(CompiledExecutable compiled) {
  File(compiled.pathToExe).deleteSync();
  if (compiled.hasBundle) {
    Directory(compiled.pathToBundle!).deleteSync(recursive: true);
  }
}

void _addWindowsMachinePath(String bin) {
  const command = r'''
$bin = $env:DCLI_SYSTEM_BIN
$path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
if (($path -split ';') -notcontains $bin) {
  [Environment]::SetEnvironmentVariable('Path', ($path.TrimEnd(';') + ';' + $bin), 'Machine')
}
''';
  final result = Process.runSync(
    'powershell.exe',
    ['-NoProfile', '-NonInteractive', '-Command', command],
    environment: {'DCLI_SYSTEM_BIN': bin},
  );
  if (result.exitCode != 0) {
    throw StateError(
      'Unable to add $bin to the machine PATH: ${result.stderr}',
    );
  }
}
