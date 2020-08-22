#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

const pubspec = 'pubspec.yaml';
const dependFile = 'dependencies.yaml';

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
  find('*.dart', recursive: true).forEach((file) {
    upgradeDartLibrary(file);
  });

  /// upgrade pubspec.yaml if found
  find('pubspec.yaml', recursive: true).forEach((file) {
    upgradePubspec(file);
  });

  /// upgrade pubspec.yaml if found
  find('lauch.json', recursive: true).forEach((file) {
    replace(file, 'dshell', 'dcli', all: true);
  });
}

void upgradeDartLibrary(String file) {
  var changed = false;
  changed |= replace(file, 'dshell', 'dcli', all: true);
  changed |= replace(file, 'DShell', 'DCli', all: true);
  changed |= replace(file, 'Dshell', 'DCli', all: true);

  if (changed) {
    print('Upgraded dart library: $file');
  }
}

void upgradePubspec(String file) {
  print('Upgrading pubspec: $file');
  upgradeDependencies(file);

  'pub upgrade'.start(workingDirectory: dirname(file), progress: Progress.printStdErr());
}

void upgradeDotDshell() {
  /// rename .dshell to .dcli
  var dot_dshell = join(HOME, '.dshell');
  var dot_dcli = join(HOME, '.dcli');

  var deleteCache = false;
  if (exists(dot_dcli)) {
    if (exists(dot_dshell) && exists(join(dot_dshell, dependFile))) {
      if (exists(join(dot_dcli, dependFile))) {
        delete(join(dot_dcli, dependFile));
      }
      // copy the old dshell file over the dcli file.
      move(join(dot_dshell, dependFile), join(dot_dcli, dependFile));
      deleteCache = true;
    }
  } else {
    if (exists(dot_dshell)) {
      /// So no .dcli so rename .dshell to .dcli
      moveDir(dot_dshell, dot_dcli);
      deleteCache = true;
    }
  }

  /// upgrade the dshell : ^1.0.0 to dcli : ^0.20.0
  var dependencies = join(dot_dcli, dependFile);
  upgradeDependencies(dependencies);

  if (deleteCache) {
    var cacheCleared = join(dot_dcli, '.cleared_cache');
    if (!exists(cacheCleared) && exists(join(dot_dcli, 'cache'))) {
      deleteDir(join(dot_dcli, 'cache'));
      createDir(join(dot_dcli, 'cache'));
    }
    touch(cacheCleared, create: true);
  }
}

void upgradeDependencies(String path) {
  if (exists(path)) {
    var lines = read(path).toList();
    move(path, '$path.bak');
    touch(path, create: true);
    for (var line in lines) {
      var tmp = line.trim().replaceAll(' ', '');
      if (tmp.startsWith('dshell')) {
        if (tmp == 'dshell:') {
          /// means its not a simple version and probably has a path on the next line.
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
