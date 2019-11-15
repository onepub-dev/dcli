import 'package:args/command_runner.dart';

import '../lib/a_command2.dart';
import '../lib/b_command.dart';

void main(List<String> arguments) {
  CommandRunner<void> runner =
      CommandRunner("drtimport", "dart import management");

  runner.addCommand(ACommand());
  runner.addCommand(BCommand());

  runner.run(arguments);
}
