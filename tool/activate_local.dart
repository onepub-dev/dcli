#! /usr/bin/env dshell
import 'dart:io';

import 'package:dshell/dshell.dart';

/// globally activates dshell from a local path rather than a public package.
///
/// defaults to activation from ..
///
/// You can change the path by passing in:
/// activate_local path=<your path>
///
void main(List<String> args) {
  var parser = ArgParser();

  parser.addCommand('help');

  // activate_local lives in the tool directory
  // so its parent directory should be the dshell package root.
  var dshellPackageRoot = dirname(dirname(Settings().scriptPath));

  parser.addOption('path', defaultsTo: dshellPackageRoot);

  var result = parser.parse(args);

  if (result.command != null) {
    print(
        '''globally activates dshell from a local path rather than a public package.

defaults to activation from ..

You can change the path by passing in:
activate_local --path=<your path>

Options:
${parser.usage}
''');
    exit(0);
  }

  dshellPackageRoot = result['path'] as String;

  print(orange('Activating dshell at $dshellPackageRoot'));

  var version = '';
  if (result.rest.length == 1) {
    version = result.rest[0];
    '${DartSdk.pubExeName} global activate --source path $dshellPackageRoot $version'
        .start(workingDirectory: dshellPackageRoot);
  } else {
    '${DartSdk.pubExeName} global activate --source path $dshellPackageRoot'
        .start(workingDirectory: dshellPackageRoot);
  }

  // make certain the dependency injection points to $path
  var dependency = join(Settings().dshellPath, 'dependencies.yaml');

  if (exists(dependency)) {
    delete(dependency);
  }

  // make certain all script see the new settings.
  'dshell install -nc'.run;

  dependency.append('dependency_overrides:');
  dependency.append('  dshell:');
  dependency.append('    path: $dshellPackageRoot');

  print('dependency.yaml');
  cat(dependency);

  //'dshell install'.run;
}
