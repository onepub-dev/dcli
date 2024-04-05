import 'package:dcli_core/dcli_core.dart';

/// Used internally to pass environment variables across an isolate
/// when launching processes.
class ProcessEnvironment {
  factory ProcessEnvironment() =>
      ProcessEnvironment._(envs, Env().caseSensitive);

  ProcessEnvironment._(this.envVars, this.caseSensitive);

  /// Environment variables
  Map<String, String> envVars;
  bool caseSensitive;
}
