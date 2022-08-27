import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../args/global_args.dart';
import '../exceptions/app_exception.dart';
import '../settings/app_settings.dart';

/// Command that can be run from the cli
/// Launches a browser showing the mailhog interface.
class ViewCommand extends Command<void> {
  /// name of the command. The user uses this name to run the command.
  @override
  String get name => 'view';

  @override
  String get description => '''
view mailhog with a passed browser.

dmailhog view [chrome|firefox]''';

  @override
  Future<void> run() async {
    final args = ViewArgs.parse(argResults, globalResults);

    final browser = args.browser;

    print(green('Starting $browser'));

    final settings = AppSettings();

    '$browser http://localhost:${settings.httpPort}'.run;
  }
}

/// Parse the command line args specific to the view command
/// including any global arguments.
class ViewArgs extends GlobalArgs {
  ViewArgs.parse(ArgResults? results, ArgResults? globalResults)
      : super(globalResults) {
    final rest = results!.rest;

    if (rest.isEmpty) {
      throw ExitException(
          1, 'view expects one argument with the name of a browser.',
          showUsage: true);
    }

    if (rest.length != 1) {
      throw ExitException(1,
          'view expects one argument with the name of a browser. Found: $rest',
          showUsage: true);
    }

    var _browser = rest[0];

    if (_browser == 'chrome') {
      _browser = 'google-chrome';
    }
    browser = _browser;
  }

  late final String browser;
}
