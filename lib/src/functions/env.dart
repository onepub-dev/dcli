import 'dart:io';

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
List<String> get PATH => Env().paths;

///
/// Internally sets an environment varaible.
/// NOTE: this does NOT affect the parent
/// processes environment.
void setEnv(String name, String value) => Env().setEnv(name, value);

class Env extends DShellFunction {
  static final Env _self = Env._internal();
  Map<String, String> envVars = {};

  factory Env() {
    return _self;
  }

  Env._internal() {
    var platformVars = Platform.environment;

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

  List<String> get paths {
    var pathEnv = env('PATH');

    var separator = ':';

    if (Platform.isWindows) {
      separator = ';';
    }
    return pathEnv.split(separator);
  }

  bool isOnPath(String binPath) {
    var found = false;
    for (var path in paths) {
      if (path == binPath) {
        found = true;
        break;
      }
    }
    return found;
  }

  void setEnv(String name, String value) => envVars[name] = value;
}
