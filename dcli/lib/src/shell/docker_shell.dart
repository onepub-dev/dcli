/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../../dcli.dart';
import 'posix_shell.dart';
import 'shell_mixin.dart';

/// When running on Docker we are often proc1
/// i.e. the one and only process running docker.
/// There may not even be a shell present in the image.
class DockerShell with ShellMixin, PosixShell {
  /// Attached to a bash shell with the given pid.
  DockerShell.withPid(this.pid);

  static bool? _inDocker;

  /// Returns true if we are running in a docker shell
  static bool get inDocker {
    if (_inDocker == null) {
      _inDocker = false;

      /// Buildx no longer creates the /.dockerenv so we need
      /// to check cgroups.
      const pathToCgroup = '/proc/1/cgroup';

      if (exists(pathToCgroup)) {
        final lines = read(pathToCgroup).toList();
        for (final line in lines) {
          if (line.contains(':docker:')) {
            _inDocker = true;
            break;
          }
        }
      }
      if (_inDocker == false) {
        /// At some point we should remove the ./dockerenv test
        /// but I'm uncertain if the cgroup method works on older containers.
        _inDocker = exists('/.dockerenv');
      }
    }

    return _inDocker!;
  }

  /// Name of the shell
  static const String shellName = 'docker';

  /// only user in docker is root.
  @override
  bool get isPrivilegedUser => true;

  /// only user in docker is root.
  @override
  bool get isPrivilegedProcess => true;

  @override
  String get loggedInUser => 'root';

  @override
  String get loggedInUsersHome => '/root';

  /// no op on docker as we are always root.
  @override
  void releasePrivileges() {}

  /// no op on docker as we are always root.
  @override
  void restorePrivileges() {}

  /// Run [action]
  /// On docker we don't have to manipulate the privlieges as we
  /// are aways root.
  @override
  void withPrivileges(RunPrivileged action, {bool allowUnprivileged = false}) {
    action();
  }

  @override
  String get installInstructions => '''
Run: 
dcli install''';

  @override
  final int? pid;

  @override
  bool get isCompletionSupported => false;

  // no shell so no tab completion
  @override
  void installTabCompletion({bool quiet = false}) =>
      throw UnsupportedError('Not supported in docker');

  /// Returns true if this shell supports
  /// modifying the shell's PATH
  @override
  bool get canModifyPath => false;

  @override
  @Deprecated('Use appendToPATH')
  bool addToPATH(String path) => appendToPATH(path);

  /// Appends the given path to the bash path if it isn't
  /// already on the path.
  @override
  bool appendToPATH(String path) =>
      throw UnsupportedError('Not supported in docker');

  /// Prepends the given path to the bash path if it isn't
  /// already on the path.
  @override
  bool prependToPATH(String path) =>
      throw UnsupportedError('Not supported in docker');

  /// Returns true if the dcil_complete has
  /// been installed as a bash auto completer
  @override
  bool get isCompletionInstalled => false;

  @override
  String get name => shellName;

  @override
  bool get hasStartScript => false;

  @override
  String get startScriptName =>
      throw UnsupportedError('Not supported in docker');

  @override
  String get pathToStartScript =>
      throw UnsupportedError('Not supported in docker');

  @override
  void addFileAssocation(String dcliPath) {
    /// no op
  }
}
