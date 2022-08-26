import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../mailhog_settings.dart';

class RunCommand extends Command<void> {
  @override
  String get description => '''
Starts mailhog.
Mail hog opens two ports:
smtp-port - the port on which it accepts smtp requests. 
web-port - the port used to view emails recieved by mailhog via your browser. 

Use `dmailhog config` to alter the ports.

To open a browser connected to mailhog run:
dmailhog <chrome|firefox> 
.''';

  @override
  String get name => 'run';

  @override
  Future<void> run() async {
    print(green('Starting mailhog'));
    final settings = MailHogSettings();

    print(orange('Access mail hog at: http://localhost:${settings.httpPort}'));

    '${settings.pathToApp} -smtp-bind-addr localhost:${settings.smtpPort} '
            '-ui-bind-addr localhost:${settings.httpPort} '
            '-api-bind-addr localhost:${settings.httpPort} '
        .run;
  }
}
