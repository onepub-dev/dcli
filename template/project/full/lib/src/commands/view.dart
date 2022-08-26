import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../mailhog_exception.dart';
import '../mailhog_settings.dart';
import 'args.dart';

class ViewCommand extends Command<void> {
  @override
  String get description => '''
view mailhog with a passed browser.

dmailhog view [chrome|firefox]''';

  @override
  String get name => 'view';

  @override
  Future<void> run() async {
    final args = ViewArgs.parse(argResults, globalResults);

    final browser = args.browser;

    print(green('Starting $browser'));

    final settings = MailHogSettings();

    '$browser http://localhost:${settings.httpPort}'.run;
  }
}

class ViewArgs extends Args {
  ViewArgs.parse(ArgResults? results, ArgResults? globalResults)
      : super(globalResults) {
    final rest = results!.rest;

    if (rest.isEmpty) {
      throw MailHogException(
          1, 'view expects one argument with the name of a browser.',
          showUsage: true);
    }

    if (rest.length != 1) {
      throw MailHogException(1,
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
