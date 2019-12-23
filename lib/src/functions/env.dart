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

  void setEnv(String name, String value) => envVars[name] = value;
}
