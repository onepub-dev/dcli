/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:stack_trace/stack_trace.dart';

import '../commands/commands.dart';
import '../commands/help.dart';
import '../util/exceptions.dart';
import 'command_line_runner.dart';

/// the 'main' for running commands.
class EntryPoint {
  ///
  factory EntryPoint() => _self ??= EntryPoint._internal();

  EntryPoint._internal() {
    _self = this;
  }

  static EntryPoint? _self;

  ///
  static void init() {
    EntryPoint._internal();
  }

  /// process the command line
  Future<int> process(List<String> arguments) async =>
      _parseCmdLine(arguments, Commands.applicationCommands);

  Future<int> _parseCmdLine(
      List<String> arguments, List<Command> availableCommands) async {
    try {
      CommandLineRunner.init(availableCommands);
      exitCode = await CommandLineRunner().process(arguments);

      verbose(() => 'Exiting with code $exitCode');

      await stderr.flush();

      return exitCode;
    } on CommandLineException catch (e) {
      printerr(red(e.toString()));
      print('');
      HelpCommand.printUsageHowTo();
      return 1;
    } on InstallException catch (e) {
      printerr(red(e.toString()));
      print('');
      return 1;
    } catch (e, stackTrace) {
      final impl = Trace.from(stackTrace);
      printerr('${e.runtimeType}: $e ');
      printerr('Stacktrace: ${impl.terse}');
      return 1;
    }
  }
}
