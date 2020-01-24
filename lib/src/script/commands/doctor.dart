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

    print('dshell doctor version ${Settings().version}');
    print('');
    print('OS: ${Platform.operatingSystem}');
    print('OS Version: ${Platform.operatingSystemVersion}');
    print('Path separator: ${Platform.pathSeparator}');
    print('');
    print('dart version    : ${DartSdk().version}');

    print('dart exe path   : ${DartSdk().exePath}');
    var dartPath = which('dart', first: true).toList()[0];
    print('dart path       : ${DartSdk().dartPath} : ${dartPath}');
    var dart2NativePath = which('dart2native', first: true).toList()[0];
    print(
        'dart2Native path: ${DartSdk().dart2NativePath} : ${dart2NativePath}');
    print('');
    var pubPath = which('pub', first: true).toList()[0];
    print('pub get path    : ${DartSdk().pubGetPath} : ${pubPath}');
    print('.pub-cache      : ${PubCache().path}');
    print('Package Config: ${Platform.packageConfig}');

    print('');

    print('HOME $HOME');
    print('PATH \n\t${PATH.join("\n\t")}');

    print('');
    print('Dart location');
    which('dart').forEach((line) => print('which: $line'));

    print('');
    print('Permissions');
    showPermissions('HOME', HOME);
    showPermissions('.dshell', Settings().dshellPath);
    showPermissions('cache', Settings().cachePath);

    showPermissions(
        'dependencies.yaml', join(Settings().dshellPath, 'dependencies.yaml'));

    showPermissions('templates', join(Settings().templatePath));
    return 0;
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
    var fstat = stat(path);
    var owner = _Owner(path);

    label = label.padRight(10);
    print('$label: ${fstat.modeString()} ${owner.toString()}   $path ');
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
    var lsLine = 'ls -alFd $path'.toList();

    if (lsLine.isEmpty) {
      throw DShellException('No file/directory matched: ${absolute(path)}');
    }

    if (lsLine.length > 1) {
      throw DShellException(
          'More than on file/directory matched: ${absolute(path)}');
    }

    var parts = lsLine[0].split(' ');
    user = parts[2];
    group = parts[3];
  }

  @override
  String toString() {
    return '$user:$group';
  }
}
