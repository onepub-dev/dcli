import 'dart:io';

import '../../../dshell.dart';
import '../command_line_runner.dart';

import '../dart_sdk.dart';
import '../flags.dart';
import 'commands.dart';

class DoctorCommand extends Command {
  static const String NAME = 'doctor';

  static const String pubCache = '.pub-cache/bin';

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
    print('dart path       : ${DartSdk().dartPath}');
    print('dart2Native path: ${DartSdk().dart2NativePath}');
    print('');
    print('pub get path    : ${DartSdk().pubGetPath}');
    print('Package Config: ${Platform.packageConfig}');

    print('');

    print('HOME $HOME');
    print('PATH \n\t${PATH.join("\n\t")}');

    print('');
    which('dart').forEach((line) => print('which: $line'));

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
}
