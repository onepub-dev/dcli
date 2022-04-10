#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

/// prints the path to this dart script.
/// Used in unit test to test the script path
/// is correct in a number of environments.
void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('platform',
        abbr: 'p',
        help: 'Dumps the output from each of the Platform properties')
    ..addFlag('verbose',
        abbr: 'v', help: 'Outputs additional logging information')
    ..addFlag(
      'script',
      abbr: 's',
      help: 'Dumps the output from each of the Script properties',
    );

  ArgResults parsed;
  try {
    parsed = parser.parse(args);
  } on FormatException catch (e) {
    printerr(red('Invalid command lineargument: ${e.message}'));
    print(parser.usage);
    exit(1);
  }

  Settings().setVerbose(enabled: parsed['verbose'] as bool);

  if (parsed['platform'] as bool) {
    dumpPlatform();
  } else if (parsed['script'] as bool) {
    dumpScript();
  } else {
    print(DartScript.current.pathToScript);
  }
}

void dumpScript() {
  final widths = <int>[30, -1];
  dump('basename', DartScript.current.basename, widths: widths);
  dump('exeName', DartScript.current.exeName, widths: widths);
  dump('isCompiled', DartScript.current.isCompiled, widths: widths);
  dump('isInstalled', DartScript.current.isInstalled, widths: widths);
  dump('isPubGlobalActivated', DartScript.current.isPubGlobalActivated,
      widths: widths);
  dump('isReadyToRun', DartScript.current.isReadyToRun, widths: widths);
  dump('pathToExe', DartScript.current.pathToExe, widths: widths);
  dump('pathToInstalledExe', DartScript.current.pathToInstalledExe,
      widths: widths);
  dump('pathToProjectRoot', DartScript.current.pathToProjectRoot,
      widths: widths);
  dump('pathToPubSpec', DartScript.current.pathToPubSpec, widths: widths);
  dump('pathToScript', DartScript.current.pathToScript, widths: widths);
  dump('pathToScriptDirectory', DartScript.current.pathToScriptDirectory,
      widths: widths);
  dump('scriptName', DartScript.current.scriptName, widths: widths);
}

void dump(String label, Object value, {required List<int> widths}) {
  print(Format.row([label, value.toString()], widths: widths));
}

void dumpPlatform() {
  final widths = <int>[30, -1];
  print(Format.row(['executable:', Platform.executable], widths: widths));
  print(Format.row(['executableArguments:', '${Platform.executableArguments}'],
      widths: widths));
  print(Format.row(['isLinux: ', '${Platform.isLinux}'], widths: widths));
  print(Format.row(['isWindows: ', '${Platform.isWindows}'], widths: widths));
  print(Format.row(['isMacOS:', '${Platform.isMacOS}'], widths: widths));
  print(Format.row(['localeName: ', (Platform.localeName)], widths: widths));
  print(
      Format.row(['localHostname:', (Platform.localHostname)], widths: widths));
  print(Format.row(['numberOfProcessors: ', '${Platform.numberOfProcessors}'],
      widths: widths));
  print(Format.row(['operatingSystem: ', (Platform.operatingSystem)],
      widths: widths));
  print(Format.row(
      ['operatingSystemVersion:', (Platform.operatingSystemVersion)],
      widths: widths));
  print(Format.row(['packageConfig:', Platform.packageConfig], widths: widths));
  print(
      Format.row(['pathSeparator:', (Platform.pathSeparator)], widths: widths));
  print(Format.row(['script:', '${Platform.script}'], widths: widths));
  print(Format.row(['version:', (Platform.version)], widths: widths));
}
