#! /usr/bin/env dcli
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

/// prints the path to this dart script.
/// Used in unit test to test the script path
/// is correct in a number of environments.
void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('ask',
        abbr: 'a',
        help: 'Ask the user for input and prints the value to stdout')
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
    printerr(red('Invalid command line argument: ${e.message}'));
    print(parser.usage);
    exit(1);
  }

  Settings().setVerbose(enabled: parsed['verbose'] as bool);

  if (parsed['platform'] as bool) {
    dumpPlatform();
  } else if (parsed['script'] as bool) {
    dumpScript();
  } else if (parsed['ask'] as bool) {
    print(ask('enter a value:'));
  } else {
    print(DartScript.self.pathToScript);
  }
}

void dumpScript() {
  final widths = <int>[30, -1];
  dump('basename', DartScript.self.basename, widths: widths);
  dump('exeName', DartScript.self.exeName, widths: widths);
  dump('isCompiled', DartScript.self.isCompiled, widths: widths);
  dump('isInstalled', DartScript.self.isInstalled, widths: widths);
  dump('isPubGlobalActivated', DartScript.self.isPubGlobalActivated,
      widths: widths);
  dump('isReadyToRun', DartScript.self.isReadyToRun, widths: widths);
  dump('pathToExe', DartScript.self.pathToExe, widths: widths);
  dump('pathToInstalledExe', DartScript.self.pathToInstalledExe,
      widths: widths);
  dump('pathToProjectRoot', DartScript.self.pathToProjectRoot, widths: widths);
  dump('pathToPubSpec', DartScript.self.pathToPubSpec, widths: widths);
  dump('pathToScript', DartScript.self.pathToScript, widths: widths);
  dump('pathToScriptDirectory', DartScript.self.pathToScriptDirectory,
      widths: widths);
  dump('scriptName', DartScript.self.scriptName, widths: widths);
}

void dump(String label, Object value, {required List<int> widths}) {
  print('$label, $value');
}

void dumpPlatform() {
  final widths = <int>[30, -1];
  print(Format().row(['executable:', Platform.executable], widths: widths));
  print(Format().row(
      ['executableArguments:', '${Platform.executableArguments}'],
      widths: widths));
  print(Format().row(['isLinux: ', '${Platform.isLinux}'], widths: widths));
  print(Format().row(['isWindows: ', '${Platform.isWindows}'], widths: widths));
  print(Format().row(['isMacOS:', '${Platform.isMacOS}'], widths: widths));
  print(Format().row(['localeName: ', Platform.localeName], widths: widths));
  print(
      Format().row(['localHostname:', Platform.localHostname], widths: widths));
  print(Format().row(['numberOfProcessors: ', '${Platform.numberOfProcessors}'],
      widths: widths));
  print(Format()
      .row(['operatingSystem: ', Platform.operatingSystem], widths: widths));
  print(Format().row(
      ['operatingSystemVersion:', Platform.operatingSystemVersion],
      widths: widths));
  print(Format()
      .row(['packageConfig:', '${Platform.packageConfig}'], widths: widths));
  print(
      Format().row(['pathSeparator:', Platform.pathSeparator], widths: widths));
  print(Format().row(['script:', '${Platform.script}'], widths: widths));
  print(Format().row(['version:', Platform.version], widths: widths));
}
