import 'package:dshell/util/for_each.dart';
import 'package:dshell/util/runnable_process.dart';

import 'dshell_function.dart';

///
/// Runs the given cli command calling [lineAction]
/// for each line the cli command returns.
/// [lineAction] is called as the command runs rather than waiting
/// for the command to complete.
///
/// ```dart
/// run("wc fred.txt").forEach((line) => print(line));
/// ```
///
/// The run function is syncronous and a such will not return
/// until the command completes.
///
/// If the command fails or returns a non-zero exitCode
/// Then a [RunCommand] exception will be thrown.
///
ForEach run(String command) => Run().run(command);

class Run extends DShellFunction {
  RunnableProcess runnable;

  ForEach run(String command) {
    ForEach forEach = ForEach();
    runnable = RunnableProcess(command);
    runnable.start();
    runnable.processUntilExit((line) => forEach.addToStdout(line),
        (line) => forEach.addToStderr(line));

    forEach.close();

    return forEach;
  }
}
