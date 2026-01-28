import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../exceptions/app_exception.dart';

/// The args package generates usage text
/// from the command and arguments we have configued.
void showUsage<T>(CommandRunner<T> runner) {
  print(blue('Usage:'));
  print(runner.usage);
}

/// Print an exception and exit.
/// Called from main() when any exception is caught.
void showException<T>(CommandRunner<T> runner, Object e) {
  if (e is UsageException) {
    final lines = e.toString().split('\n');
    final error = lines.first;
    printerr(red('Error: $error'));
    final usage = lines.skip(1).join('\n');
    printerr(usage);
  } else if (e is AppException) {
    printerr(red('Error: ${e.message}'));

    if (e.showUsage) {
      showUsage(runner);
    }
  } else {
    printerr(red('Error: $e'));
    showUsage(runner);
  }
}
