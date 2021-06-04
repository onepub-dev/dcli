import 'package:meta/meta.dart';

import '../../dcli.dart';
import 'shell_detection.dart';

/// an abstract class which allows each shell (bash, zsh)
/// to provide specific implementation of features
/// required by DCli.
@immutable
abstract class Shell {
  /// The name of the shell
  /// e.g. bash
  String get name;

  /// True if this shell supports a start script or configuration file.
  /// e.g. a script that is run by the shell or a configuration file
  /// that is read when the shell starts.
  bool get hasStartScript;

  /// Returns the  name of the shell's startup script or
  /// configuration file
  /// e.g. .bashrc
  String get startScriptName;

  /// Returns the path to the shell's start script or config file
  /// e.g /home/<user>/.bashrc
  String? get pathToStartScript;

  /// Returns true if the shells name matches
  /// the passed [name].
  /// The comparison is case insensitive.
  bool matchByName(String name);

  /// Adds a path to the start script
  /// returns true if adding the path was successful
  bool addToPATH(String path) => false;

  /// Called during the install so that an OS that needs
  /// to create a file association between .dart and dcli
  /// can create that association.
  /// The implementor is responsible for not adding
  /// the association if it already exists.
  void addFileAssocation(String dcliPath);

  ///
  bool get isCompletionSupported => false;

  ///
  bool get isCompletionInstalled => false;

  /// A derived class should overload this method and return true
  /// if the script is running under sudo.
  bool get isSudo => false;

  /// If the shell supports tab completion then
  /// install it.
  /// If [quiet] is true then suppress any console output except
  /// for errors.
  void installTabCompletion({bool quiet = true}) => throw UnimplementedError();

  /// Returns the username of the logged in user.
  ///
  /// Linux:
  /// If you are running sudo this will still return the actual
  /// username rather than root.
  String? get loggedInUser;

  /// Returns true if the current user this process
  /// is running as has esclated privileges.
  ///
  /// e.g. root under posix, Administrator under windows.
  ///
  /// If you have called [releasePrivileges] then
  /// this method will return false unless you are within
  /// a privileged block create by [withPrivileges].
  ///
  /// You can check if the process was launched with priviliges
  /// via calling [isPrivilegedProcess].
  ///
  /// In Linux and osx terminology this method returns
  /// true if the  effective uid is root (uid == 0).
  bool get isPrivilegedUser => false;

  /// Returns true if running a privileged action would
  /// cause a password to be requested.
  ///
  /// Linux/OSX: will return true if the sudo password is not currently
  /// cached and we are not already running as a privileged user.
  ///
  /// Windows: This will always return false as Windows is never
  /// able to escalate privileges.
  bool get isPrivilegedPasswordRequired => true;

  /// Returns true if the process was launched as a priviliged process.
  ///
  /// Calling [releasePrivileges] has no affect on this call.
  ///
  /// Under Linux and OSX this means that the process's real uid
  /// is root (uid = 0).
  /// Under Windows this means that the process was lauched via
  /// 'Run as Administrator'.
  ///
  bool get isPrivilegedProcess => false;

  /// On Linux and osx systems makes the script run as
  /// a non-privileged user even when started with sudo.
  ///
  /// This method is used to overcome issues when running as sudo
  /// where the script would change the ownership to root:root
  /// for any created/modified file.
  ///
  /// This method is normally called as the first line of your
  /// main() method.
  ///
  /// Calling this method on Windows is unnecessary but harmless.
  ///
  /// Calling this method for a non-privileged user has no affect.
  ///
  /// On Linux and OSX releasing privileges sets the uid and gid
  /// to the user's original
  /// privileges so any files that are created/modified get the original
  /// user's uid/gid.
  ///
  /// You should use this method in conjuctions with [withPrivileges]
  /// so that only specific parts of your code run with privileges.
  ///
  /// You must NEVER call [releasePrivileges] within a [withPrivileges]
  /// action.
  ///
  /// ```dart
  /// void main(){
  ///
  ///  ///  downgrade script to not run as sudo
  ///  Shell.current.releasePrivileges();
  ///
  ///  /// ... do some non-sudo things
  ///
  ///  /// any code within the following code block will be run
  ///  /// with sudo privileges.
  ///  Shell.current.withPrivileges(() {
  ///    copyTree('\etc\keys', '\some\insecure\location');
  ///   });
  ///}
  ///```
  /// See: [restorePrivileges]
  ///   [withPrivileges]
  void releasePrivileges();

  /// If [releasePrivileges] has been called
  /// then this method will restore those privileges
  /// See [releasePrivileges] for details
  ///
  /// See: [releasePrivileges]
  ///   [withPrivileges]
  void restorePrivileges();

  /// When a script is run under sudo on Linux and osx and you
  /// have previously called [releasePrivileges] then this method
  /// will run [action] with root privileges.
  ///
  /// If you attempt to call [withPrivileges] when not running
  /// as a privileged process a [ShellException] will be thrown.
  ///
  /// Use [isPrivilegedProcess] to check if your script was started
  /// as a priviliged process.
  ///
  /// Nesting [withPrivileges] blocks is allowed as a convenience.
  ///
  /// You must NEVER call [releasePrivileges] within a [withPrivileges]
  /// action.
  ///
  /// See: [restorePrivileges]
  ///   [releasePrivileges]
  void withPrivileges(RunPrivileged action);

  /// Returns a message informing the user that they need to run
  /// as a priviledged user to run an app.
  String privilegesRequiredMessage(String appname);

  /// Returns instructions on how to install DCli.
  String get installInstructions;

  /// Installs dart and dcli.
  /// Returns true if dart was installed.
  /// Returns false if dart was already installed.
  bool install({bool installDart = false}) => false;

  /// Some OS/Shell combinations have some preconditions that must
  /// be met before dcli can be installed.
  ///
  /// This method returns a String describing those preconditions
  /// or null if there are no preconditions.
  String? checkInstallPreconditions() => null;

  /// The pid of the current shell
  int? get pid;

  static Shell? _current;

  /// Returns the user shell that this script was launched from
  /// e.g. bash, powershell, ....
  /// If the shell can't be deteremined then the [UnknownShell] is returned.
  ///
  static Shell get current => _current ??= ShellDetection().identifyShell();
}

/// Typedef for the withPrivileges function.
typedef RunPrivileged = void Function();

/// Thrown when an exception occurs in the Shell detection and support methods.
class ShellException extends DCliException {
  /// Thrown when the [move] function encouters an error.
  ShellException(String reason) : super(reason);
}
