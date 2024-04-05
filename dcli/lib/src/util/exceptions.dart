import 'package:dcli_core/dcli_core.dart';

/// Thrown when an invalid argument is passed to a command.
class InvalidArgumentException extends DCliException {
  ///
  InvalidArgumentException(super.message);
}

class InvalidTemplateException extends DCliException {
  /// Thrown when an invalid template is selected
  InvalidTemplateException(super.message);
}

/// Thrown if an error is encountered during an install
class InstallException extends DCliException {
  /// Thrown if an error is encountered during an install
  InstallException(super.message);
}

class ProcessSyncException extends DCliException {
  ProcessSyncException(super.message);
}
