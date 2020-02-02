import 'dart:io';

import 'package:dshell/src/util/pub_cache.dart';

import '../../../dshell.dart';
import '../command_line_runner.dart';

import '../dart_sdk.dart';
import '../flags.dart';
import 'commands.dart';

class DoctorCommand extends Command {
  static const String NAME = 'doctor';

  DoctorCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    if (subarguments.isNotEmpty) {
      throw CommandLineException(
          "'dshell doctor' does not take any arguments. Found $subarguments");
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
    return 0;
  }

  void colprint(String label, String value, {int pad = 25}) {
    print('${label.padRight(pad)}: ${value}');
  }

  /// Removes the users home directory from a path replacing it with ~
  String privatePath(String part1,
      [String part2,
      String part3,
      String part4,
      String part5,
      String part6,
      String part7]) {
    return truepath(part1, part2, part3, part4, part5, part6, part7)
        .replaceAll(HOME, '~');
  }

  @override
  String description() =>
      """Running 'dshell doctor' provides diagnostic information on your install.""";

  @override
  String usage() => 'Doctor';

  @override
  List<String> completion(String word) {
    return <String>[];
  }

  void showPermissions(String label, String path) {
    if (exists(path)) {
      var fstat = stat(path);

      var owner = _Owner(path);

      label = label.padRight(20);

      var username = env('USERNAME');
      if (username != null) {
        colprint('$label',
            '${fstat.modeString()} <user>:${(owner.group == owner.user ? '<group>' : owner.group)}   ${privatePath(path)} ');
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
