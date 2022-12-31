import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart' hide ExitException;

import '../args/global_args.dart';
import '../exceptions/app_exception.dart';
import '../settings/app_settings.dart';

class ConfigCommand extends Command<void> {
  ConfigCommand() {
    argParser
      ..addOption(smtpPortOption,
          abbr: 's',
          defaultsTo: '1025',
          help: 'The port to listen for smtp requests')
      ..addOption(httpPortOption,
          abbr: 'w',
          defaultsTo: '8025',
          help: 'The port to listen for http requests')
      ..addFlag('ask',
          abbr: 'a', help: 'Prompts the user to enter the settings');
  }
  static const smtpPortOption = 'smtp-port';
  static const httpPortOption = 'http-port';

  /// name of the command. The user uses this name to run the command.
  @override
  String get name => 'config';

  @override
  String get description => '''
Configures the mailhog ports.
Mail hog opens two ports:
smtp-port - the port on which it accepts smtp requests. 
web-port - the port used to view emails recieved by mailhog via your browser. 

Pass --ask to be prompted for the settings or pass one or both of the port
arguments to update them without user interaction.

.''';

  @override
  Future<void> run() async {
    final args = ConfigArgs.parse(argResults, globalResults);

    final settings = AppSettings();

    if (args.ask) {
      // ask the user to configure each setting and save it.
      settings
        ..smtpPort = int.parse(ask('SMTP Port:',
            defaultValue: '${settings.smtpPort}',
            validator: Ask.all([Ask.integer, Ask.valueRange(1024, 65355)])))
        ..httpPort = int.parse(ask('HTTP Port:',
            defaultValue: '${settings.httpPort}',
            validator: Ask.all([Ask.integer, Ask.valueRange(1024, 65355)])));
    } else {
      settings
        ..smtpPort = args.smtpPort
        ..httpPort = args.httpPort;
    }

    if (settings.smtpPort == settings.httpPort) {
      throw ExitException(
          1, 'The SMTP Port and the HTTP Port may not be the same value.',
          showUsage: false);
    }
    settings.save();
  }
}

/// Parse the command line args specific to the config command
/// including any global arguments.
class ConfigArgs extends GlobalArgs {
  ConfigArgs.parse(ArgResults? results, ArgResults? globalResults)
      : super(globalResults) {
    final settings = AppSettings();

    var smtpPort = settings.smtpPort;
    var httpPort = settings.httpPort;
    var ask = true;

    if (results!.rest.isNotEmpty) {
      throw ExitException(
          1,
          'config does not take any positional arguments. '
          'Found ${results.rest}',
          showUsage: true);
    }
    // smtp port
    if (results.wasParsed(ConfigCommand.smtpPortOption)) {
      ask = false;
      final port =
          int.tryParse(results[ConfigCommand.smtpPortOption] as String);
      if (port == null) {
        throw ExitException(
            1, 'Invalid integer passed for ${ConfigCommand.smtpPortOption}',
            showUsage: false);
      }
      smtpPort = port;
    }

    // http port
    if (results.wasParsed(ConfigCommand.httpPortOption)) {
      ask = false;
      final port =
          int.tryParse(results[ConfigCommand.httpPortOption] as String);
      if (port == null) {
        throw ExitException(
            1, 'Invalid integer passed for ${ConfigCommand.httpPortOption}',
            showUsage: false);
      }
      httpPort = port;
    }

    smtpPort = smtpPort;
    httpPort = httpPort;

    ask = ask;
  }

  late final int smtpPort;
  late final int httpPort;
  late final bool ask;
}
