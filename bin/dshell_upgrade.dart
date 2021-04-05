#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

const pubspec = 'pubspec.yaml';

/// Use this script to upgrade a project from dshell to dcli
void main() {
  // if (!exists(pubspec))
  // {
  //   /// not a project so confirm that the user wants the local files upgraded.
  //   Script.fromFile(script)

  //   print(orange(''))
  // }

  /// rename .dshell to .dcli
  upgradeDotDshell();

  upgradeProject();

  /// recompile dcli scripts
}

void upgradeProject() {
  find('*.dart').forEach(upgradeDartLibrary);

  /// upgrade pubspec.yaml if found
  find('pubspec.yaml').forEach(upgradePubspec);

  /// upgrade pubspec.yaml if found
  find('lauch.json').forEach((file) {
    replace(file, 'dshell', 'dcli', all: true);
  });
}

void upgradeDartLibrary(String file) {
  var changed = 0;
  changed += replace(file, 'dshell', 'dcli', all: true);
  changed += replace(file, 'DShell', 'DCli', all: true);
  changed += replace(file, 'Dshell', 'DCli', all: true);

  if (changed > 0) {
    print('Upgraded dart library: $file. Changed $changed lines');
  }
}

void upgradePubspec(String file) {
  print('Upgrading pubspec: $file');
  upgradeDependencies(file);

  'pub upgrade'
      .start(workingDirectory: dirname(file), progress: Progress.printStdErr());
}

void upgradeDotDshell() {
  /// rename .dshell to .dcli
  final dotDShell = join(HOME, '.dshell');
  final dotDCli = join(HOME, '.dcli');

  var deleteCache = false;
  if (exists(dotDCli)) {
    deleteCache = true;
  } else {
    if (exists(dotDShell)) {
      /// So no .dcli so rename .dshell to .dcli
      moveDir(dotDShell, dotDCli);
      deleteCache = true;
    }
  }

  if (deleteCache) {
    final cacheCleared = join(dotDCli, '.cleared_cache');
    if (!exists(cacheCleared) && exists(join(dotDCli, 'cache'))) {
      deleteDir(join(dotDCli, 'cache'));
      createDir(join(dotDCli, 'cache'));
    }
    touch(cacheCleared, create: true);
  }
}

void upgradeDependencies(String path) {
  if (exists(path)) {
    final lines = read(path).toList();
    move(path, '$path.bak');
    touch(path, create: true);
    for (final line in lines) {
      final tmp = line.trim().replaceAll(' ', '');
      if (tmp.startsWith('dshell')) {
        if (tmp == 'dshell:') {
          /// means its not a simple version and probably has a path
          /// on the next line.
          /// This will only happen if someone is doing dev on dshell.
          path.append('  dcli:');
        } else {
          path.append('  dcli: ^0.20.0');
        }
      } else {
        path.append(line.replaceAll('dshell', 'dcli'));
      }
    }
    delete('$path.bak');
  }
}
