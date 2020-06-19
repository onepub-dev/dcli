import 'package:meta/meta.dart';

/// an abstract class which allows each shell (bash, zsh)
/// to provide specific implementation of features
/// required by DShell.
@immutable
abstract class Shell {
  ///
  bool get isCompletionInstalled;

  ///
  bool get isCompletionSupported;

  /// If the shell supports tab completion then
  /// install it.
  void installTabCompletion();

  /// Returns the path to the shell's start script
  String get startScriptPath;

  /// Returns the  name of the shell's startup script
  /// e.g. .bashrc
  String get startScriptName;

  /// The name of the shell
  /// e.g. bash
  String get name;

  /// Returns true if the shells name matches
  /// the passed [name].
  /// The comparison is case insensitive.
  bool matchByName(String name);

  /// Added a path to the start script
  /// returns true if adding the path was successful
  bool addToPath(String path);

  /// Returns the username of the logged in user.
  String get loggedInUser;

  /// Returns [true] if the current user has esclated
  /// privileges.
  /// e.g. root under posix, Administrator under windows.
  bool get isPrivilegedUser;

  /// Returns a message informing the user that they need to run
  /// as a priviledged user to run an app.
  String privilegesRequiredMessage(String appname);
}
