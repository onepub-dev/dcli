import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

class GlobalArgs {
  /// We parse any global Args here
  /// Each argument parsed here must be added to the CommandRunner
  /// in main.dart.
  /// The args parser for each command that you implment must derive
  /// from this class so that the global args are available to
  /// each command.
  GlobalArgs(ArgResults? argResults) {
    /// If the --debug flag was passed then enable DCli's verbose mode.
    Settings().setVerbose(enabled: argResults!['debug'] as bool);
  }
}
