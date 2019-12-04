import 'dart:io';

import 'package:dshell/functions/copy.dart';
import 'package:dshell/functions/create_dir.dart';
import 'package:dshell/functions/is.dart';
import 'package:dshell/script/command_line_runner.dart';
import 'package:dshell/settings.dart';

import '../flags.dart';
import 'commands.dart';

class InstallCommand extends Command {
  static const String NAME = "install";

  InstallCommand() : super(NAME);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    int exitCode = 0;

    if (subarguments.isNotEmpty) {
      throw CommandLineException(
          "'dshell install' does not take any arguments. Found $subarguments");
    }

    if (!exists(Settings().configRootPath)) {
      print("Creating ${Settings().configRootPath}");
      createDir(Settings().configRootPath);
    } else {
      print("Found ${Settings().configRootPath}");
    }

    print("Platform.version ${Platform.version}");

    print("Copying dshell (${Platform.executable}) to /usr/bin/dshell");
    copy(Platform.executable, "/usr/bin/dshell");

    if (!exists(Settings().templatePath)) {
      print("Creating Template directory in: ${Settings().templatePath}");
      createDir(Settings().templatePath);
    }

    print("dshell installation complete.");
    print("Create your first dshell script using:");
    print("dshell create <scriptname>.dart");
    print("Run your script by typing:");
    print("./<scriptname>.dart");

    return exitCode;
  }

  @override
  String description() =>
      "Installs the script using dart's native Installer. Only required if you want super fast execution.";

  @override
  String usage() => "Install <script path.dart>";
}
