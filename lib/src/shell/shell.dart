import 'package:dcli/dcli.dart';
import 'package:dcli/src/shell/shell_detection.dart';
import 'package:meta/meta.dart';

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

  ///
  bool get isCompletionSupported => false;

  ///
  bool get isCompletionInstalled => false;

  bool get isSudo => false;

  /// If the shell supports tab completion then
  /// install it.
  /// If [quiet] is trie the suppress any console output except
  /// for errors.
  void installTabCompletion({bool? quiet}) => throw UnimplementedError();

  /// Returns the username of the logged in user.
  ///
  /// Linux:
  /// If you are running sudo this will still return the actual
  /// username rather than root.
  String? get loggedInUser;

  /// Returns true if the current user has esclated
  /// privileges.
  /// e.g. root under posix, Administrator under windows.
  bool get isPrivilegedUser => false;

  /// Returns a message informing the user that they need to run
  /// as a priviledged user to run an app.
  String privilegesRequiredMessage(String appname);

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

  int? get pid;

  static Shell? _current;

  /// Returns the user shell that this script was launched from
  /// e.g. bash, powershell, ....
  /// If the shell can't be deteremined then the [UnknownShell] is returned.
  ///
  static Shell get current => _current ??= ShellDetection().identifyShell();
}
