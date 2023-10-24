import 'package:dcli_core/dcli_core.dart';

import 'process/synchronous.dart';

/// Used internally to pass environment variables across an isolate
/// boundary when using [ProcessSync] to synchronously call a process.
class ProcessEnvironment {
  factory ProcessEnvironment() =>
      ProcessEnvironment._(envs, Env().caseSensitive);

  ProcessEnvironment._(this.envVars, this.caseSensitive);

  /// Environment variables
  Map<String, String> envVars;
  bool caseSensitive;
}
