/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli/dcli.dart';

import '../script/flags.dart';
import '../util/completion.dart';
import '../util/exceptions.dart';
import 'commands.dart';
import 'run.dart';

/// implementst the 'doctor' command
class DoctorCommand extends Command {
  ///
  DoctorCommand() : super(_commandName);
  static const _commandName = 'doctor';

  @override
  Future<int> run(List<Flag> selectedFlags, List<String> subarguments) async {
    var showScriptDetails = false;

    late DartScript script;
    if (subarguments.length == 1) {
      showScriptDetails = true;
      final scriptPath = subarguments[0];
      RunCommand.validateScriptPath(scriptPath);
      script = DartScript.fromFile(scriptPath);
    }
    if (subarguments.length > 1) {
      throw InvalidCommandArgumentException(
        "'dcli doctor' takes zero or one arguments. Found $subarguments",
      );
    }

    _colprint(['DCli version', Settings().version]);
    print('');

    _printPlatform();
    print('');

    _printExePaths();
    print('');

    _printPubCache();
    print('');

    _printPackageConfig();
    print('');

    _printPATH();
    print('');

    _printShell();
    print('');

    _printDartLocations();
    print('');

    _printPermissions();
    print('');

    if (showScriptDetails) {
      script.doctor;
    }
    return 0;
  }

  void _printDartLocations() {
    print('dart location(s)');
    which('dart').paths.forEach((line) => _colprint(['', line]));
  }

  void _printPermissions() {
    print('permissions');
    _showPermissions('HOME', HOME);
    _showPermissions('.dcli', Settings().pathToDCli);

    _showPermissions('project template', Settings().pathToTemplateProject);
    _showPermissions('script template', Settings().pathToTemplateScript);

    _showPermissions('pub cache', PubCache().pathTo);
  }

  void _printShell() {
    print('shell settings');
    _colprint([r'$SHELL', env['SHELL'] ?? '']);

    final shell = Shell.current;
    _colprint(['detected', shell.name]);

    if (shell.hasStartScript) {
      final startScriptPath = shell.pathToStartScript;
      _colprint(['start script', privatePath(startScriptPath ?? 'not found')]);
    } else {
      _colprint(['start sript', 'not supported by shell']);
    }
  }

  void _printPATH() {
    print('PATH');
    for (final path in PATH) {
      _colprint(['', privatePath(path)]);
    }
  }

  void _printPackageConfig() {
    _colprint([
      'package config',
      privatePath(Platform.packageConfig ?? 'not passed')
    ]);
  }

  void _printPubCache() {
    final pathToPubCache = PubCache().pathTo;
    _colprint(['pub cache', privatePath(pathToPubCache)]);

    _colprint(
      ['PUB_CACHE Env', '${envs.containsKey(PubCache.envVarPubCache)}'],
    );
  }

  void _printExePaths() {
    final pathToDCli = DCliPaths().pathToDCli;
    _colprint([
      'dcli path',
      if (pathToDCli == null) 'Not found' else privatePath(pathToDCli)
    ]);
    _colprint(
        ['dart exe path', privatePath(DartSdk().pathToDartExe ?? 'not found')]);

    final dartPath = which(DartSdk.dartExeName).path;
    _colprint([
      'dart path',
      privatePath(DartSdk().pathToDartExe ?? 'not found'),
      'which: ${privatePath(dartPath ?? 'not found')}'
    ]);

    if (DartSdk().useDartCommand) {
      _colprint(['compiler', "using 'dart compile exe'"]);
    } else {
      _colprint(['compiler', "using 'dart2native'"]);
      final dart2NativePath = which(DartSdk.dart2NativeExeName).path;

      if (dart2NativePath != null) {
        _colprint([
          'dart2Native path',
          privatePath(DartSdk().pathToDartToNativeExe ?? 'not found'),
          'which: ${privatePath(dart2NativePath)}'
        ]);
      } else {
        _colprint([
          'dart2Native path',
          'Not Found',
        ]);
      }
    }
    print('');

    if (DartSdk().useDartCommand) {
      _colprint(['pub', "using 'dart pub'"]);
    } else {
      final pubPath = which(DartSdk.pubExeName).path;

      if (pubPath != null) {
        _colprint([
          'pub path',
          privatePath(DartSdk().pathToPubExe ?? 'not found'),
          'which: ${privatePath(pubPath)}'
        ]);
      } else {
        _colprint([
          'pub path',
          'not Found',
        ]);
      }
      _colprint(['Pub cache', privatePath(PubCache().pathTo)]);
    }
  }

  void _printPlatform() {
    _colprint(['os', Platform.operatingSystem]);
    print(
      Format().row(
        ['os version', Platform.operatingSystemVersion],
        widths: [17, -1],
      ),
    );
    _colprint(['path separator', Platform.pathSeparator]);
    print('');
    _colprint(['dart version', DartSdk().version]);
  }

  void _colprint(List<String?> cols) {
    //cols[0] = green(cols[0]);
    print(Format().row(cols, widths: [17, 55], delimiter: ' '));
  }

  @override
  String description({bool extended = false}) => """
Running 'dcli doctor' provides diagnostic information on your install 
   and optionally a specific script.""";

  @override
  String usage() => 'doctor [<script path.dart>]';

  @override
  List<String> completion(String word) => completionExpandScripts(word);

  void _showPermissions(String label, String path) {
    var finallabel = label;
    if (exists(path)) {
      final fstat = stat(path);

      final owner = _Owner(path);

      finallabel = label.padRight(20);

      final username = Shell.current.loggedInUser;
      if (username != null) {
        print(
          Format().row(
            [
              finallabel,
              fstat.modeString(),
              '<user>:${owner.group == owner.user ? '<user>' : owner.group}',
              '${privatePath(path)} '
            ],
            widths: [17, 9, 16, -1],
            alignments: [
              TableAlignment.left,
              TableAlignment.left,
              TableAlignment.middle,
              TableAlignment.left
            ],
          ),
        );
      }
    } else {
      _colprint([finallabel, '${privatePath(path)} does not exist']);
    }
  }

  @override
  List<Flag> flags() => [];
}

class _Owner {
  _Owner(String path) {
    if (Settings().isWindows) {
      user = 'Unknown';
      group = 'Unknown';
    } else {
      final lsLine = 'ls -alFd $path'.firstLine;

      if (lsLine == null) {
        throw DCliException('No file/directory matched ${truepath(path)}');
      }

      final parts = lsLine.split(' ');
      user = parts[2];
      group = parts[3];
    }
  }

  String? user;
  String? group;

  @override
  String toString() => '$user:$group';
}
