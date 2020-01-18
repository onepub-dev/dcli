import 'dart:io';

import 'package:dshell/src/util/dshell_exception.dart';

import '../settings.dart';
import 'dshell_function.dart';
import '../util/log.dart';

/// Gets an environment variable
///
///```dart
///String path = env("PATH");
///```
///
String env(String name) => Env().env(name);

/// Tests if the given [path] is contained
/// in the OS's PATH environment variable.
bool isOnPath(String path) => Env().isOnPath(path);

/// Returns the list of directory paths that are contained
/// in the OS's PATH environment variable.
/// They are returned in the same order that they appear within
/// the PATH environment variable (as order is important.)
List<String> get PATH => Env().PATH;

/// returns the path to the OS specific HOME directory
String get HOME => Env().HOME;

///
/// Internally sets an environment varaible.
/// NOTE: this does NOT affect the parent
/// processes environment.
void setEnv(String name, String value) => Env().setEnv(name, value);

class Env extends DShellFunction {
  static Env _self = Env._internal();
  Map<String, String> envVars = {};

  factory Env() {
    return _self;
  }

  Env._internal() {
    var platformVars = Platform.environment;

    // build a local map with all of the OS environment vars.
    for (var entry in platformVars.entries) {
      envVars.putIfAbsent(entry.key, () => entry.value);
    }
  }

  String env(String name) {
    if (Settings().debug_on) {
      Log.d('name:  ${name}');
    }
    return envVars[name];
  }

  List<String> get PATH {
    var pathEnv = env('PATH');

    var separator = ':';

    if (Platform.isWindows) {
      separator = ';';
    }
    return pathEnv.split(separator);
  }

  ///
  /// Gets the path to the users home directory
  /// using the enviornment var appropriate for the user's OS.
  String get HOME {
    String home;

    if (Settings().isWindows) {
      home = env('AppData');
    } else {
      home = env('HOME');
    }

    if (home == null) {
      if (Settings().isWindows) {
        throw DShellException(
            "Unable to find the 'AppData' enviroment variable. Please ensure it is set and try again.");
      } else {
        throw DShellException(
            "Unable to find the 'HOME' enviroment variable. Please ensure it is set and try again.");
      }
    }
    return home;
  }

  bool isOnPath(String binPath) {
    var found = false;
    for (var path in PATH) {
      if (path == binPath) {
        found = true;
        break;
      }
    }
    return found;
  }

  void setEnv(String name, String value) => envVars[name] = value;

  static void setMock(Env mockEnv) {
    _self = mockEnv;
  }
}
