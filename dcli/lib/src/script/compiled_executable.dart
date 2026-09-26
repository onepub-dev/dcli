import 'dart:io';

import 'package:path/path.dart';

import '../../dcli.dart';

/// A compiled executable, optionally backed by a hidden application bundle.
class CompiledExecutable {
  /// Creates a compilation result.
  CompiledExecutable(this.pathToExe, {this.hasBundle = false});

  /// The public executable (a native launcher when [hasBundle] is true).
  final String pathToExe;

  /// Whether the executable needs a hidden bundle beside it.
  final bool hasBundle;

  /// The bundle beside this executable, or null for standalone executables.
  String? get pathToBundle => hasBundle ? bundlePath(pathToExe) : null;

  /// The hidden bundle location for an executable.
  static String bundlePath(String executable) {
    var name = basename(executable);
    if (Platform.isWindows && name.toLowerCase().endsWith('.exe')) {
      name = name.substring(0, name.length - 4);
    }
    return join(dirname(executable), '.$name.bundle');
  }

  /// Moves the executable and its entire bundle to [destination].
  ///
  /// The bundle follows the destination's name, so installation may rename the
  /// launcher. Each application owns its libraries, avoiding name collisions.
  void install(String destination, {bool overwrite = false}) {
    if (equals(absolute(pathToExe), absolute(destination))) {
      return;
    }
    if (Directory(destination).existsSync()) {
      throw InvalidArgumentException(
        'The executable destination must be a file: $destination',
      );
    }
    final targetBundle = Directory(bundlePath(destination));
    if (!overwrite &&
        (FileSystemEntity.typeSync(destination, followLinks: false) !=
                FileSystemEntityType.notFound ||
            (hasBundle && targetBundle.existsSync()))) {
      throw InvalidArgumentException(
        'An executable or bundle already exists at $destination',
      );
    }
    if (!hasBundle) {
      move(pathToExe, destination, overwrite: overwrite);
      return;
    }

    // Stage on the destination filesystem before replacing an installed app.
    // Replacing the directory also removes libraries dropped by a rebuild.
    final staging = Directory(
      dirname(destination),
    ).createTempSync('.dcli-install-');
    final previousBundle = join(staging.path, 'previous');
    var backedUp = false;
    var published = false;
    var preserveBackup = false;
    try {
      final nextBundle = Directory(join(staging.path, 'bundle'))..createSync();
      copyTree(pathToBundle!, nextBundle.path, includeHidden: true);
      final nextExe = File(pathToExe).copySync(join(staging.path, 'launcher'));
      if (targetBundle.existsSync()) {
        targetBundle.renameSync(previousBundle);
        backedUp = true;
      }
      try {
        nextBundle.renameSync(targetBundle.path);
        published = true;
        move(nextExe.path, destination, overwrite: overwrite);
      } catch (_) {
        // Keep the backup if a filesystem error prevents restoration.
        preserveBackup = backedUp;
        if (published) {
          targetBundle.deleteSync(recursive: true);
        }
        if (backedUp) {
          Directory(previousBundle).renameSync(targetBundle.path);
        }
        preserveBackup = false;
        rethrow;
      }
      File(pathToExe).deleteSync();
      Directory(pathToBundle!).deleteSync(recursive: true);
    } finally {
      if (!preserveBackup) {
        staging.deleteSync(recursive: true);
      }
    }
  }
}
