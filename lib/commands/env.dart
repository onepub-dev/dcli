import 'dart:io';

import 'command.dart';
import 'settings.dart';
import '../util/log.dart';

/// Gets an environment variable
///
///```dart
///String path = env("PATH");
///```
///
String env(String name) => Env().env(name);

class Env extends Command {
  static Env _self = Env._internal();
  Map<String, String> envVars;

  factory Env() {
    return _self;
  }

  Env._internal() {
    envVars = Platform.environment;
  }

  String env(String name) {
    if (Settings().debug_on) {
      Log.d("name:  ${name}");
    }
    return envVars[name];
  }
}
