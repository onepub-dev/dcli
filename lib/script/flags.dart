import '../settings.dart';

class Flags {
  static List<Flag> applicationFlags = [VerboseFlag()];

  static bool get isVerbose => null;

  static Flag findFlag(String flagSwitch, List<Flag> flags) {
    Flag found;
    for (Flag flag in flags) {
      if (nameSwitch(flag) == flagSwitch || abbrSwitch(flag) == flagSwitch) {
        found = flag;
        break;
      }
    }
    return found;
  }

  static String nameSwitch(Flag flag) => "--${flag._name}";
  static String abbrSwitch(Flag flag) => "-${flag.abbreviation}";

  static bool isFlag(String argument) {
    return (argument.startsWith('-') || argument.startsWith('--'));
  }

  static bool isSet(Flag flag) {
    return Settings().isFlagSet(flag);
  }

  static void set(Flag flag) {
    Settings().setFlag(flag);
  }
}

abstract class Flag {
  String _name;

  Flag(this._name);

  String get name => _name;

  String get abbreviation;

  String usage() => "--$_name | -$abbreviation";

  String description();
}

class VerboseFlag extends Flag {
  static const NAME = "verbose";

  VerboseFlag() : super(NAME);

  String get abbreviation => "v";

  String description() => "If set, turns on verbose logging.";
}
