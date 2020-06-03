import '../../dshell.dart';

/// Used by dshell to interacte with the shell
/// environment when we are unable to detect
/// what shell is active.
class UnknownShell implements Shell {
  @override
  bool addToPath(String path) {
    if (Settings().isMacOS) {
      return addPathToMacOsPathd(path);
    } else if (Settings().isLinux) {
      return _addPathToLinuxPath(path);
    } else {
      return false;
    }
  }

  ///
  bool addPathToMacOsPathd(String path) {
    var success = false;
    if (!isOnPath(path)) {
      var macOSPathPath = join(rootPath, 'etc', 'path.d');

      try {
        if (!exists(macOSPathPath)) {
          createDir(macOSPathPath, recursive: true);
        }
        if (exists(macOSPathPath)) {
          join(macOSPathPath, 'dshell').write(path);
        }
        success = true;
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e) {
        // ignore write permission problems.
        printerr(red(
            "Unable to add dshell/bin to path as we couldn't write to $macOSPathPath"));
      }
    }
    return success;
  }

  bool _addPathToLinuxPath(String path) {
    var success = false;
    if (!isOnPath(path)) {
      var profile = join(HOME, '.profile');
      try {
        if (exists(profile)) {
          var export = 'export PATH=\$PATH:$path';
          if (!read(profile).toList().contains(export)) {
            profile.append(export);
            success = true;
          }
        }
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e) {
        // ignore write permission problems.
        printerr(red(
            "Unable to add dshell/bin to path as we couldn't write to $profile"));
      }
    }
    return success;
  }

  @override
  void installTabCompletion() {}

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => 'Unknown';

  @override
  String get startScriptName => null;

  @override
  String get startScriptPath => null;

  @override
  bool get isPrivilegedUser => false;

  @override
  String get loggedInUser => null;

  @override
  String privilegesRequiredMessage(String app) {
    return 'You need to be a privileged user to run $app';
  }
}
