#! /usr/bin/env dshell
import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/functions/env.dart';
import 'package:dshell/src/pubspec/global_dependencies.dart';

/// globally activates dshell from a local path rather than a public package.
///
/// defaults to activation from ..
///
/// You can change the path by passing in:
/// activate_local path=<your path>
///
void main(List<String> args) {
  var parser = ArgParser();
  parser.addFlag('verbose', abbr: 'v');

  parser.addCommand('help');

  // activate_local lives in the tool directory
  // so its parent directory should be the dshell package root.
  var dshellPackageRoot = dirname(dirname(Settings().scriptPath));

  parser.addOption('path', defaultsTo: dshellPackageRoot);

  var result = parser.parse(args);

  if (result.wasParsed('verbose')) {
    Settings().setVerbose(enabled: true);
  }

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

  var dshellBin = join(dshellPackageRoot, 'bin', '${DShellPaths().dshellName}');
  if (exists(dshellBin)) {
    delete(dshellBin);
  }

  /// alter the version so we can tell we are activating the local version
  ///
  var versionfile =
      join(dshellPackageRoot, 'lib', 'src', 'version', 'version.g.dart');
  var versionbackup = '$versionfile.bak';
  move(versionfile, versionbackup, overwrite: true);
  versionfile.write("String packageVersion = 'activate_local_version';");

  /// use the global dshell version to compile the local version.
  'dshell compile $dshellBin.dart'.run;

  // make certain the dependency injection points to $path
  var dependency = join(Settings().dshellPath, GlobalDependencies.filename);

  if (exists(dependency)) {
    delete(dependency);
  }

  /// set the path the local dshell.
  Env().pathPrepend(join(dshellPackageRoot, 'bin'));

  // make certain all script see the new settings.
  '${DShellPaths().dshellName} install -nc'.run;

  dependency.append('dependency_overrides:');
  dependency.append('  dshell:');
  dependency.append('    path: $dshellPackageRoot');

  print(GlobalDependencies.filename);
  cat(dependency);

  'bash'.run;

  move(versionbackup, versionfile);
  //'dshell install'.run;
}
