import 'package:args/command_runner.dart';
import 'package:dartcli/move_command.dart';
import 'package:dartcli/patch_command.dart';
import 'package:dartcli/pubspec.dart';

void main(List<String> arguments) async {
  PubSpec pubSpec = PubSpec();
  await pubSpec.load();
  String version = pubSpec.version;

  CommandRunner<void> runner =
      CommandRunner("drtimport", "Dart import management, version: ${version}");

  runner.addCommand(MoveCommand());
  runner.addCommand(PatchCommand());

  await runner.run(arguments);
}
