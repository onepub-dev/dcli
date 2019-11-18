import 'package:dshell/util/runnable_process.dart';

import 'command.dart';

///
/// Runs the given cli command calling [lineAction]
/// for each line the cli command returns.
/// [lineAction] is called as the command runs rather than waiting
/// for the command to complete.
///
/// The run function is syncronous and a such will not return
/// until the command completes.
///
/// If the command fails or returns a non-zero exitCode
/// Then a [RunCommand] exception will be thrown.
///
void run(String command, {LineAction stdout, LineAction stderr}) =>
    Run().run(command, stdout: stdout, stderr: stderr);

class Run extends Command {
  RunnableProcess runnable;

  void run(String command, {LineAction stdout, LineAction stderr}) {
    runnable = RunnableProcess(command);
    runnable.start();
    runnable.processUntilExit(stdout, stderr);
  }
}

class RunException extends CommandException {
  RunException(String reason) : super(reason);
}
