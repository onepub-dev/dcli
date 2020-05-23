import 'package:meta/meta.dart';

import '../../dshell.dart';
import '../settings.dart';

/// helper flass for manageing flags.
@immutable
class Flags {
  /// Find the flag that matches [flagSwitch].
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

  /// the format of a named switch '--name'
  static String nameSwitch(Flag flag) => '--${flag._name}';

  /// the format of an abbreviated switch '-n'
  static String abbrSwitch(Flag flag) => '-${flag.abbreviation}';

  /// true if the given argument starts with '-' or '--'.
  static bool isFlag(String argument) {
    return (argument.startsWith('-') || argument.startsWith('--'));
  }

  /// true if a global flag in the [Settings] class is set.
  bool isSet(Flag flag) {
    return Settings().isFlagSet(flag);
  }

  /// sets a global flag in the [Settings] class.
  void set(Flag flag) {
    Settings().setFlag(flag);
  }
}

/// base class for command line flags (--name, -v ...)
abstract class Flag {
  final String _name;

  ///
  Flag(this._name);

  /// name of the flag
  String get name => _name;

  /// abbreviation for the flag.
  String get abbreviation;

  /// return true if the flag can take a value
  /// after an equals sign
  /// e.g. -v=/var/log/syslog
  bool get isOptionSupported => false;

  /// returns the usage for this flag
  String usage() => '--$_name | -$abbreviation';

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(covariant Flag flag) {
    return flag.name == _name;
  }

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => name.hashCode;

  /// [Flag] implementations must overload this to return a
  /// description of the flag used in the usage statement.
  String description();

  /// Called if an option is passed to a flag
  /// and the flag supports options.
  /// If the option value is invalid then throw a
  /// InvalidFlagOption exception.

  /// Override this method if your flag takes an optional argument after an = sign.
  ///
  set option(String value) {
    assert(
        !isOptionSupported, 'You must implement option setter for $_name flag');
  }

  /// override this method if your flag takes an optional argument after an = sign.
  /// this method should reutrn the value after the = sign.
  String get option => null;
}

///
class VerboseFlag extends Flag {
  static const _flagName = 'verbose';
  static final _self = VerboseFlag._internal();

  String _option;

  @override
  String get option => _option;

  /// true if the flag has an option.
  bool get hasOption => _option != null;

  ///
  factory VerboseFlag() {
    return _self;
  }

  VerboseFlag._internal() : super(_flagName);

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
  String usage() => '--$_flagName[=<log path>] | -$abbreviation[=<log path>]';

  @override
  String description() => '''If passed, turns on verbose logging to the console.
      If you provide a log path then logging is written to the given logfile.''';
}

/// throw if we found an invalid flag.
class InvalidFlagOption implements Exception {
  ///
  String message;

  ///
  InvalidFlagOption(this.message);
}
