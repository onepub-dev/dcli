#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

///
/// running unit tests from vs-code doesn't seem to work as it spawns
/// two isolates and runs tests in parallel (even when using the -j1 option)
/// Given we are actively modifying the file system this is a bad idea.
/// So this script forces the test to run serially via the -j1 option.
///
void main(List<String> args) {
  print(orange('Cleaning old test and build artifacts'));

  if (exists('/tmp/dcli')) {
    print('Deleting old test runs. This can take a while...');
    deleteDir('/tmp/dcli');
  }

    final projectRoot = DartProject.fromPath(pwd).pathToProjectRoot;
  if (!isDCliRunningFromSource()) {
    print(
        'Activating dcli from source so we are testing against latest version');


    /// run pub get and only display errors.
    DartSdk().globalActivateFromPath(projectRoot);

  }
    /// warm up all test packages.
    for (final pubspec
        in find('pubspec.yaml', workingDirectory: projectRoot).toList()) {
	if (DartSdk().isPubGetRequired(dirname(pubspec)))
	{
		print('Running pub get in ${dirname(pubspec)}');
      		DartSdk().runPubGet(dirname(pubspec));
	}
    }
}

/// We need to have a single shared copy of the dcli source
/// If we use the actual dcli dev directory then we contaminate
/// the .packages/.dart_tool config with paths into the
/// /tmp .pub_cache we use during testing.
// void copyDCil() {
//   final dcliTargetPath = join(Directory.systemTemp.path, '.dcli', 'source');

//   if (exists(dcliTargetPath)) {
//     {
//       final targetCreationTime = stat(dcliTargetPath).modified;

//       final dcliLastChanged = lastChangeToDcli();
//     }
//     createDir(dcliTargetPath, recursive: true);
//   }
// }

DateTime lastChangeToDcli() {
  var lastChange = DateTime.now().subtract(const Duration(days: 365));

  find('*', workingDirectory: DartProject.fromPath(pwd).pathToProjectRoot)
      .forEach((line) {
    final modified = stat(line).modified;
    if (modified.isAfter(lastChange)) {
      lastChange = modified;
    }
  });

  return lastChange;
}

bool isDCliRunningFromSource() {
  /// run pub global list to see if dcli is run from a local path.
  final line = DartSdk()
      .runPub(args: ['global', 'list'], progress: Progress.capture())
      .lines
      .firstWhere((line) => line.startsWith('dcli'), orElse: () => 'dcli');

  return line.contains('at path');
}
