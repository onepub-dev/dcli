#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/functions/env.dart';
import 'package:dcli/src/pubspec/global_dependencies.dart';

/// globally activates dcli from a local path rather than a public package.
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
  // so its parent directory should be the dcli package root.
  var dcliPackageRoot = dirname(dirname(Settings().scriptPath));

  parser.addOption('path', defaultsTo: dcliPackageRoot);

  var result = parser.parse(args);

  if (result.wasParsed('verbose')) {
    Settings().setVerbose(enabled: true);
  }

  if (result.command != null) {
    print('''globally activates dcli from a local path rather than a public package.

defaults to activation from ..

You can change the path by passing in:
activate_local --path=<your path>

Options:
${parser.usage}
''');
    exit(0);
  }

  dcliPackageRoot = result['path'] as String;

  print(orange('Activating dcli at $dcliPackageRoot'));

  var version = '';
  if (result.rest.length == 1) {
    version = result.rest[0];
    '${DartSdk.pubExeName} global activate --source path $dcliPackageRoot $version'
        .start(workingDirectory: dcliPackageRoot);
  } else {
    '${DartSdk.pubExeName} global activate --source path $dcliPackageRoot'.start(workingDirectory: dcliPackageRoot);
  }

  var dcliBin = join(dcliPackageRoot, 'bin', '${DCliPaths().dcliName}');
  if (exists(dcliBin)) {
    delete(dcliBin);
  }

  /// alter the version so we can tell we are activating the local version
  ///
  var versionfile = join(dcliPackageRoot, 'lib', 'src', 'version', 'version.g.dart');
  var versionbackup = '$versionfile.bak';
  move(versionfile, versionbackup, overwrite: true);
  versionfile.write("String packageVersion = 'activate_local_version';");

  /// use the global dcli version to compile the local version.
  'dcli compile $dcliBin.dart'.run;

  // make certain the dependency injection points to $path
  var dependency = join(Settings().dcliPath, GlobalDependencies.filename);

  if (exists(dependency)) {
    delete(dependency);
  }

  /// set the path the local dcli.
  Env().pathPrepend(join(dcliPackageRoot, 'bin'));

  // make certain all script see the new settings.
  '${DCliPaths().dcliName} install -nc'.run;

  dependency.append('dependency_overrides:');
  dependency.append('  dcli:');
  dependency.append('    path: $dcliPackageRoot');

  print(GlobalDependencies.filename);
  cat(dependency);

  'bash'.run;

  move(versionbackup, versionfile);
  //'dcli install'.run;
}
