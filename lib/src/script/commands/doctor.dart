import 'dart:io';

import '../../shell/shell_detection.dart';

import '../../../dshell.dart';
import '../../pubspec/global_dependencies.dart';

import '../../util/completion.dart';
import '../../util/format.dart';
import '../../util/pub_cache.dart';
import '../../util/truepath.dart';

import '../command_line_runner.dart';

import '../dart_sdk.dart';
import '../flags.dart';
import '../script.dart';
import '../virtual_project.dart';
import 'commands.dart';

/// implementst the 'doctor' command
class DoctorCommand extends Command {
  static const String _commandName = 'doctor';

  ///
  DoctorCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var showScriptDetails = false;
    VirtualProject project;
    if (subarguments.length == 1) {
      showScriptDetails = true;
      var scriptPath = subarguments[0];
      Script.validate(scriptPath);
      project = VirtualProject.create(Script.fromFile(scriptPath));
    }
    if (subarguments.length > 1) {
      throw InvalidArguments(
          "'dshell doctor' takes zero or one arguments. Found $subarguments");
    }

    _colprint(['Dshell version', '${Settings().version}']);
    print('');
    _colprint(['OS', '${Platform.operatingSystem}']);
    print(Format.row(['OS Version', '${Platform.operatingSystemVersion}'],
        widths: [17, -1]));
    _colprint(['Path separator', '${Platform.pathSeparator}']);
    print('');
    _colprint(['dart version', '${DartSdk().version}']);
    print('');

    var dshellPath = which('dshell').firstLine;
    _colprint([
      'dshell path',
      '${dshellPath == null ? 'Not found' : privatePath(dshellPath)}'
    ]);
    _colprint(['dart exe path', '${privatePath(DartSdk().dartExePath)}']);
    var dartPath = which(DartSdk.dartExeName, first: true).firstLine;
    _colprint([
      'dart path',
      '${privatePath(DartSdk().dartExePath)}',
      'which: ${privatePath(dartPath)}'
    ]);
    var dart2NativePath =
        which(DartSdk.dart2NativeExeName, first: true).firstLine;
    _colprint([
      'dart2Native path',
      '${privatePath(DartSdk().dart2NativePath)}',
      'which: ${privatePath(dart2NativePath)}'
    ]);
    print('');
    var pubPath = which(DartSdk.pubExeName, first: true).firstLine;
    _colprint([
      'pub get path',
      '${privatePath(DartSdk().pubPath)}',
      'which: ${privatePath(pubPath)}'
    ]);
    _colprint(['Pub cache', '${privatePath(PubCache().path)}']);

    if (Platform.packageConfig == null) {
      _colprint(['Package Config', 'Not Passed']);
    } else {
      _colprint(['Package Config', '${privatePath(Platform.packageConfig)}']);
    }

    print('');

    print('PATH');
    for (var path in PATH) {
      _colprint(['', privatePath(path)]);
    }
    print('');
    _colprint(['\$SHELL', '${env('SHELL')}']);
    if (!Settings().isWindows) {
      _colprint(['True SHELL', '${ShellDetection().getShellName()}']);

      var shell = ShellDetection().identifyShell();
      var startScriptPath = shell.startScriptPath;

      if (startScriptPath == null) {
        _colprint(['Shell Start Script', 'Not Found']);
      } else {
        _colprint(['Shell Start Script', '${privatePath(startScriptPath)}']);
      }
    }

    print('');
    print('Dart location(s)');
    which('dart').forEach((line) => _colprint(['', line]));

    print('');
    print('Permissions');
    _showPermissions('HOME', HOME);
    _showPermissions('.dshell', Settings().dshellPath);
    _showPermissions('cache', Settings().dshellCachePath);

    _showPermissions(GlobalDependencies.filename,
        join(Settings().dshellPath, GlobalDependencies.filename));

    _showPermissions('templates', Settings().templatePath);

    print('');
    print(join('.dshell', GlobalDependencies.filename));
    var gd = GlobalDependencies();
    for (var d in gd.dependencies) {
      _colprint(['  ${d.name}', '${d.rehydrate()}']);
    }

    if (showScriptDetails) {
      project.doctor;
    }
    return 0;
  }

  void _colprint(List<String> cols) {
    //cols[0] = green(cols[0]);
    print(Format.row(cols, widths: [17, 55], delimiter: ' '));
  }

  @override
  String description() =>
      """Running 'dshell doctor' provides diagnostic information on your install 
   and optionally a specific script.""";

  @override
  String usage() => 'doctor [<script path.dart>]';

  @override
  List<String> completion(String word) {
    return completionExpandScripts(word);
  }

  void _showPermissions(String label, String path) {
    if (exists(path)) {
      var fstat = stat(path);

      var owner = _Owner(path);

      label = label.padRight(20);

      var username = env('USERNAME');
      if (username != null) {
        print(Format.row([
          '$label',
          '${fstat.modeString()}',
          '<user>:${(owner.group == owner.user ? '<user>' : owner.group)}',
          '${privatePath(path)} '
        ], widths: [
          17,
          9,
          16,
          -1
        ], alignments: [
          TableAlignment.left,
          TableAlignment.left,
          TableAlignment.middle,
          TableAlignment.left
        ]));
      }
    } else {
      _colprint(['$label', '${privatePath(path)} does not exist']);
    }
  }

  @override
  List<Flag> flags() {
    return [];
  }
}

class _Owner {
  String user;
  String group;

  _Owner(String path) {
    if (Platform.isWindows) {
      user = 'Unknown';
      group = 'Unknown';
    } else {
      var lsLine = 'ls -alFd $path'.firstLine;

      if (lsLine == null) {
        throw DShellException('No file/directory matched ${absolute(path)}');
      }

      var parts = lsLine.split(' ');
      user = parts[2];
      group = parts[3];
    }
  }

  @override
  String toString() {
    return '$user:$group';
  }
}
