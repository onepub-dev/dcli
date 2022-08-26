import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../mailhog_exception.dart';
import '../mailhog_settings.dart';
import 'args.dart';

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
  String get name => 'config';

  @override
  Future<void> run() async {
    final args = ConfigArgs.parse(argResults, globalResults);

    final settings = MailHogSettings();

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
      throw MailHogException(
          1, 'The SMTP Port and the HTTP Port may not be the same value.',
          showUsage: false);
    }
    settings.save();
  }
}

/// Class used to parse the command line args passed to the
/// config command.
class ConfigArgs extends Args {
  ConfigArgs.parse(ArgResults? results, ArgResults? globalResults)
      : super(globalResults) {
    final settings = MailHogSettings();

    var _smtpPort = settings.smtpPort;
    var _httpPort = settings.httpPort;
    var _ask = true;

    if (results!.rest.isNotEmpty) {
      throw MailHogException(1,
          'config does not take any positional arguments. Found ${results.rest}',
          showUsage: true);
    }
    // smtp port
    if (results.wasParsed(ConfigCommand.smtpPortOption)) {
      _ask = false;
      final port =
          int.tryParse(results[ConfigCommand.smtpPortOption] as String);
      if (port == null) {
        throw MailHogException(
            1, 'Invalid integer passed for ${ConfigCommand.smtpPortOption}',
            showUsage: false);
      }
      _smtpPort = port;
    }

    // http port
    if (results.wasParsed(ConfigCommand.httpPortOption)) {
      _ask = false;
      final port =
          int.tryParse(results[ConfigCommand.httpPortOption] as String);
      if (port == null) {
        throw MailHogException(
            1, 'Invalid integer passed for ${ConfigCommand.httpPortOption}',
            showUsage: false);
      }
      _httpPort = port;
    }

    smtpPort = _smtpPort;
    httpPort = _httpPort;

    ask = _ask;
  }

  late final int smtpPort;
  late final int httpPort;
  late final bool ask;
}
