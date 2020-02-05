import 'package:dshell/dshell.dart';
import '../settings.dart';

class Flags {
  Flag findFlag(String flagSwitch, List<Flag> flags) {
    Flag found;
    var foundOption = false;

    // Some flags allow an option after an equals sign
    var parts = flagSwitch.split('=');
    if (parts.length == 2) {
      foundOption = true;
      flagSwitch = parts[0];
    }
    for (var flag in flags) {
      if (nameSwitch(flag) == flagSwitch || abbrSwitch(flag) == flagSwitch) {
        if (foundOption) {
          if (flag.isOptionSupported) {
            flag.option = parts[1];
          } else {
            throw InvalidFlagOption(
                'The flag $flagSwitch was passed with an option but it does not support options.');
          }
        }
        found = flag;
        break;
      }
    }
    return found;
  }

  static String nameSwitch(Flag flag) => '--${flag._name}';
  static String abbrSwitch(Flag flag) => '-${flag.abbreviation}';

  static bool isFlag(String argument) {
    return (argument.startsWith('-') || argument.startsWith('--'));
  }

  bool isSet(Flag flag) {
    return Settings().isFlagSet(flag);
  }

  void set(Flag flag) {
    Settings().setFlag(flag);
  }
}

abstract class Flag {
  final String _name;

  Flag(this._name);

  String get name => _name;

  String get abbreviation;

  /// return true if the flag can take a value
  /// after an equals sign
  /// e.g. -v=/var/log/syslog
  bool get isOptionSupported => false;

  /// Set to true if the flag had a valid option
  /// passed.
  bool hasOption = false;

  /// If the flag has an option this method is called to fetch it.
  String optionValue;

  String usage() => '--$_name | -$abbreviation';

  @override
  bool operator ==(covariant Flag flag) {
    return flag.name == _name;
  }

  String description();

  /// Called if an option is passed to a flag
  /// and the flag supports options.
  /// If the option value is invalid then throw a
  /// InvalidFlagOption exception.

  /// Override this method if you flag takes an optional argument after an = sign.
  ///
  set option(String value) {
    assert(!isOptionSupported, 'You must implement setOption for $_name flag');
  }

  String get option => null;
}

class VerboseFlag extends Flag {
  static const NAME = 'verbose';
  static final _self = VerboseFlag._internal();

  String _option;

  @override
  String get option => _option;

  @override
  bool get hasOption => _option != null;

  factory VerboseFlag() {
    return _self;
  }

  VerboseFlag._internal() : super(NAME);

  @override
  bool get isOptionSupported => true;

  @override
  set option(String value) {
    // check that the value contains a path and that
    // the path exists.
    if (!exists(dirname(value))) {
      throw InvalidFlagOption(
          "The log file's directory '${truepath(dirname(value))} does not exists. Create the directory first.");
    } else {
      _option = value;
      touch(value, create: true);
      value.truncate();
    }
  }

  @override
  String get abbreviation => 'v';

  @override
  String usage() => '--$NAME[=<log path>] | -$abbreviation[=<log path>]';

  @override
  String description() => '''If passed, turns on verbose logging to the console.
      If you provide a log path then logging is written to the given logfile.''';
}

class InvalidFlagOption implements Exception {
  String message;
  InvalidFlagOption(this.message);
}
