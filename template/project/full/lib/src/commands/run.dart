import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../settings/app_settings.dart';

class RunCommand extends Command<void> {
  /// name of the command. The user uses this name to run the command.
  @override
  String get name => 'run';

  @override
  String get description => '''
Starts mailhog.
Mail hog opens two ports:
smtp-port - the port on which it accepts smtp requests. 
http-port - the port used to view emails recieved by mailhog via your browser. 

Use `dmailhog config` to alter the ports.

To open a browser connected to mailhog run:
dmailhog run <chrome|firefox> 
''';

  @override
  Future<void> run() async {
    print(green('Starting mailhog'));
    final settings = AppSettings();

    print(orange('Access mail hog at: http://localhost:${settings.httpPort}'));

    /// run mailhog app.
    '${settings.pathToMailHogApp} '
            '-smtp-bind-addr localhost:${settings.smtpPort} '
            '-ui-bind-addr localhost:${settings.httpPort} '
            '-api-bind-addr localhost:${settings.httpPort} '
        .run;
  }
}
