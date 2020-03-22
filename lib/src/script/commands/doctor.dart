import 'dart:io';

import 'package:dshell/src/pubspec/global_dependencies.dart';
import 'package:dshell/src/util/completion.dart';
import 'package:dshell/src/util/format.dart';
import 'package:dshell/src/util/pub_cache.dart';
import 'package:dshell/src/util/truepath.dart';

import '../../../dshell.dart';
import '../command_line_runner.dart';

import '../dart_sdk.dart';
import '../flags.dart';
import '../script.dart';
import '../virtual_project.dart';
import 'commands.dart';

class DoctorCommand extends Command {
  static const String NAME = 'doctor';

  DoctorCommand() : super(NAME);

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
      throw CommandLineException(
          "'dshell doctor' takes zero or one arguments. Found $subarguments");
    }

    colprint(['Dshell version', '${Settings().version}']);
    print('');
    colprint(['OS', '${Platform.operatingSystem}']);
    print(Format.row(['OS Version', '${Platform.operatingSystemVersion}'],
        widths: [17, -1]));
    colprint(['Path separator', '${Platform.pathSeparator}']);
    print('');
    colprint(['dart version', '${DartSdk().version}']);
    print('');

    var dshellPath = which('dshell').firstLine;
    colprint([
      'dshell path',
      '${dshellPath == null ? 'Not found' : privatePath(dshellPath)}'
    ]);
    colprint(['dart exe path', '${privatePath(DartSdk().dartExePath)}']);
    var dartPath = which(DartSdk.dartExeName, first: true).firstLine;
    colprint([
      'dart path',
      '${privatePath(DartSdk().dartExePath)}',
      'which: ${privatePath(dartPath)}'
    ]);
    var dart2NativePath =
        which(DartSdk.dart2NativeExeName, first: true).firstLine;
    colprint([
      'dart2Native path',
      '${privatePath(DartSdk().dart2NativePath)}',
      'which: ${privatePath(dart2NativePath)}'
    ]);
    print('');
    var pubPath = which(DartSdk.pubExeName, first: true).firstLine;
    colprint([
      'pub get path',
      '${privatePath(DartSdk().pubPath)}',
      'which: ${privatePath(pubPath)}'
    ]);
    colprint(['Pub cache', '${privatePath(PubCache().path)}']);

    if (Platform.packageConfig == null) {
      colprint(['Package Config', 'Not Passed']);
    } else {
      colprint(['Package Config', '${privatePath(Platform.packageConfig)}']);
    }

    print('');

    print('PATH');
    PATH.forEach((path) => colprint(['', privatePath(path)]));
    print('');
    colprint(['\$SHELL', '${env('SHELL')}']);
    if (!Settings().isWindows) {
      colprint(['True SHELL', '${ShellDetection().getShellName()}']);

      var shell = ShellDetection().identifyShell();
      var startScriptPath = shell.startScriptPath;

      if (startScriptPath == null) {
        colprint(['Shell Start Script', 'Not Found']);
      } else {
        colprint(['Shell Start Script', '${privatePath(startScriptPath)}']);
      }
    }

    print('');
    print('Dart location(s)');
    which('dart').forEach((line) => colprint(['', line]));

    print('');
    print('Permissions');
    showPermissions('HOME', HOME);
    showPermissions('.dshell', Settings().dshellPath);
    showPermissions('cache', Settings().dshellCachePath);

    showPermissions(GlobalDependencies.filename,
        join(Settings().dshellPath, GlobalDependencies.filename));

    showPermissions('templates', Settings().templatePath);

    print('');
    print(join('.dshell', GlobalDependencies.filename));
    var gd = GlobalDependencies();
    gd.dependencies
        .forEach((d) => colprint(['  ${d.name}', '${d.rehydrate()}']));

    if (showScriptDetails) {
      project.doctor;
    }
    return 0;
  }

  void colprint(List<String> cols) {
    //cols[0] = green(cols[0]);
    print(Format.row(cols, widths: [17, 40], delimiter: ' '));
  }

  @override
  String description() =>
      """Running 'dshell doctor' provides diagnostic information on your install 
   and optionally a specific script.""";

  @override
  String usage() => 'doctor [<script path.dart>]';

  @override
  List<String> completion(String word) {
    return completion_expand_scripts(word);
  }

  void showPermissions(String label, String path) {
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
          TableAlignment.LEFT,
          TableAlignment.LEFT,
          TableAlignment.MIDDLE,
          TableAlignment.LEFT
        ]));
      }
    } else {
      colprint(['$label', '${privatePath(path)} does not exist']);
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
