import 'dart:cli';
import 'dart:io';

import 'package:dshell/script/flags.dart';
import 'package:dshell/util/stack_trace_impl.dart';

import 'args.dart';
import 'command_line_runner.dart';
import 'commands/commands.dart';
import 'log.dart';

import 'package:dshell/script/pub_get.dart';

class EntryPoint {
  String version;

  int process(String appName, String version, List<String> arguments) {
    return parseCmdLine(appName, arguments, Flags.applicationFlags,
        Commands.applicationCommands);
  }

  int parseCmdLine(String appname, List<String> arguments,
      List<Flag> availableFlags, List<Command> availableCommands) {
    try {
      final int exitCode =
          CommandLineRunner(appname, availableFlags, availableCommands)
              .process(arguments);

      Log.error('Exiting with code $exitCode', LogLevel.verbose);

      waitFor<void>(stderr.flush());

      return exitCode;
    } on ArgsException catch (e) {
      Log.error(e.toString());
      return 1;
    } on PubGetException catch (e) {
      Log.error(' Running "pub get" failed with exit code ${e.exitCode}!');
      Log.error(e.stderr, LogLevel.verbose);
      return 1;
    } catch (e, stackTrace) {
      StackTraceImpl impl = StackTraceImpl.fromStackTrace(stackTrace);
      Log.error('Exception occured: ${e}');
      Log.error('Stacktrace: ${impl.formatStackTrace()}');
    }

    return 0;
  }

  void printHelp() {
    print('${Args().appname}: Executes standalone Dart shell scripts.');
    print('');
    print('Usage: dscript [-v] [-k] [script-filename] [arguments...]');
    print('Example: -v calc.dart 20 + 5');
    print('');
    print('Options:');
    print('-v: Verbose');
    print('-k: Keep temporary project files');
    print('');
    print('');
    print('Sub-commands:');
    print('help: Prints help text');
    print('version: Prints version');
  }

  bool probeSubCommands(List<String> args) {
    if (args.isEmpty) {
      print('Version: $version');
      print('');
      printHelp();
      return true;
    }

    switch (args[0]) {
      case 'version':
        print(version);
        return true;
      case 'help':
        printHelp();
        return true;
    }

    return false;
  }
}
