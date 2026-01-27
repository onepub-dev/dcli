/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;

import '../commands/commands.dart';
import '../commands/help.dart';
import '../commands/run.dart';
import '../util/exceptions.dart';
import 'flag.dart';
import 'flags.dart';
import 'help_flag.dart';
import 'selected_flags.dart';
import 'verbose_flag.dart';

/// Runs a dcli script.
class CommandLineRunner {
  static CommandLineRunner? _self;

  /// the list of flags set on the command line.
  static List<Flag> globalFlags = [VerboseFlag(), HelpFlag()];

  // Tracks the set of flags the users set on the command line.
  final _flagsSet = Flags();

  Map<String, Command> _availableCommands;

  ///
  factory CommandLineRunner() {
    if (_self == null) {
      throw Exception('The CommandLineRunner has not been intialised');
    }
    return _self!;
  }

  CommandLineRunner._internal(this._availableCommands);

  /// initialises the [CommandLineRunner]
  static void init(List<Command> availableCommands) {
    _self = CommandLineRunner._internal(Commands.asMap(availableCommands));
  }

  /// Process the command line arguments to run the command.
  Future<int> process(List<String> arguments) async {
    int? exitCode;

    var success = false;

    // Find the command and run it.
    Command? command;
    var cmdArguments = <String>[];

    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];

      if (Flags.isFlag(argument)) {
        final flag = _flagsSet.findFlag(argument, globalFlags);

        if (flag != null) {
          if (_flagsSet.isSet(flag)) {
            throw DuplicateOptionsException(argument);
          }
          _flagsSet.set(flag);
          if (flag == VerboseFlag()) {
            _configVerbose(flag);
          } else if (flag == HelpFlag()) {
            command = HelpCommand();
            success = true;
            break;
          }

          continue;
        } else {
          throw UnknownFlag(argument);
        }
      }

      // there may only be one command on the cli.
      command = Commands.findCommand(argument, _availableCommands);
      if (command != null) {
        if (i + 1 < arguments.length) {
          cmdArguments = arguments.sublist(i + 1);
        }
        verbose(() => 'Found command $command');
        success = true;
        break;
      }

      // its not a flag, its not a command, so it must be a script.
      command = RunCommand();
      verbose(() => 'Found Script $argument');
      cmdArguments = arguments.sublist(i);
      success = true;
      break;
    }

    if (success) {
      // get the script name and remaning args as they are the arguments
      // for the command to process.
      exitCode =
          await command!.run(SelectedFlags().selectedFlags, cmdArguments);
    } else {
      throw InvalidCommandArgumentException('Invalid arguments passed.');
    }
    return exitCode;
  }

  void _configVerbose(Flag flag) {
    verbose(() => 'Setting flag: ${flag.name}');
    verbose(() => 'DCli Version: ${Settings().version}');
    final verboseFlag = flag as VerboseFlag;
    if (verboseFlag.hasOption) {
      core.Settings().captureLogOutput().listen((record) {
        verboseFlag.option
            .append('${record.level.name}: ${record.time}: ${record.message}');
      });
    }
  }
}
