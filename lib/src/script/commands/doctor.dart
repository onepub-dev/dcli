import 'dart:io';

import 'package:dshell/src/pubspec/global_dependencies.dart';
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
    VirtualProject script;
    if (subarguments.length == 1) {
      showScriptDetails = true;
      script = VirtualProject(
          Settings().dshellCachePath, Script.fromFile(subarguments[0]));
    }
    if (subarguments.length > 1) {
      throw CommandLineException(
          "'dshell doctor' does zero or one arguments. Found $subarguments");
    }

    colprint('Dshell doctor version', '${Settings().version}');
    print('');
    colprint('OS', '${Platform.operatingSystem}');
    colprint('OS Version', '${Platform.operatingSystemVersion}');
    colprint('Path separator', '${Platform.pathSeparator}');
    print('');
    colprint('dart version', '${DartSdk().version}');

    colprint('dart exe path', '${privatePath(DartSdk().exePath)}');
    var dartPath = which('dart', first: true).firstLine;
    colprint('dart path',
        '${privatePath(DartSdk().dartPath)} : ${privatePath(dartPath)}');
    var dart2NativePath = which('dart2native', first: true).firstLine;
    colprint('dart2Native path',
        '${privatePath(DartSdk().dart2NativePath)} : ${privatePath(dart2NativePath)}');
    print('');
    var pubPath = which('pub', first: true).firstLine;
    colprint('pub get path',
        '${privatePath(DartSdk().pubGetPath)} : ${privatePath(pubPath)}');
    colprint('.pub-cache', '${privatePath(PubCache().path)}');

    if (Platform.packageConfig == null) {
      colprint('Package Config', 'Not Passed');
    } else {
      colprint('Package Config', '${privatePath(Platform.packageConfig)}');
    }

    print('');

    print('PATH\n\t${privatePath(PATH.join("\n\t"))}');
    colprint('\$SHELL', '${env('SHELL')}');
    if (!Settings().isWindows) {
      colprint('True SHELL', '${ShellDetection().getShellName()}');

      var shell = ShellDetection().identifyShell();
      var startScriptPath = shell.startScriptPath;

      if (startScriptPath == null) {
        colprint('Shell Start Script', 'Not Found');
      } else {
        colprint('Shell Start Script', '${privatePath(startScriptPath)}');
      }
    }

    print('');
    print('Dart location(s)');
    which('dart').forEach((line) => colprint('', line));

    print('');
    print('Permissions');
    showPermissions('HOME', HOME);
    showPermissions('.dshell', Settings().dshellPath);
    showPermissions('cache', Settings().dshellCachePath);

    showPermissions(
        'dependencies.yaml', join(Settings().dshellPath, 'dependencies.yaml'));

    showPermissions('templates', Settings().templatePath);

    print('');
    print('.dshell/dependencies.yaml');
    var gd = GlobalDependencies();
    gd.dependencies.forEach((d) => colprint(
        '  ${d.name}', '${d.isPath ? privatePath(d.path) : d.version}'));

    if (showScriptDetails) {
      script.doctor;
    }
    return 0;
  }

  void colprint(String label, String value, {int pad = 25}) {
    print('${label.padRight(pad)}: ${value}');
  }

  @override
  String description() =>
      """Running 'dshell doctor' provides diagnostic information on your install and optionally a specific script.""";

  @override
  String usage() => 'doctor [<script path.dart>]';

  @override
  List<String> completion(String word) {
    var dartScripts = find('*.dart', recursive: false).toList();
    var results = <String>[];
    for (var script in dartScripts) {
      if (script.startsWith(word)) {
        results.add(script);
      }
    }
    return results;
  }

  void showPermissions(String label, String path) {
    if (exists(path)) {
      var fstat = stat(path);

      var owner = _Owner(path);

      label = label.padRight(20);

      var username = env('USERNAME');
      if (username != null) {
        colprint('$label',
            '${fstat.modeString()} <user>:${(owner.group == owner.user ? '<user>' : owner.group)}   ${privatePath(path)} ');
      }
    } else {
      colprint('$label', '${privatePath(path)} does not exist');
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
    var lsLine = 'ls -alFd $path'.firstLine;

    if (lsLine == null) {
      throw DShellException('No file/directory matched ${absolute(path)}');
    }

    var parts = lsLine.split(' ');
    user = parts[2];
    group = parts[3];
  }

  @override
  String toString() {
    return '$user:$group';
  }
}
