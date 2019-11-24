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

  static bool isSet(Flag flag, Map<String, Flag> selectedFlags) {
    return selectedFlags.containsValue(flag);
  }
}

abstract class Flag {
  String _name;

  Flag(this._name);

  String get name => _name;

  String get abbreviation;

  String usage(String appname) => "--$_name | -$abbreviation";

  String description(String appname);
}

class VerboseFlag extends Flag {
  static const NAME = "verbose";

  VerboseFlag() : super(NAME);

  String get abbreviation => "v";

  String description(String appname) => "If set, turns on verbose logging.";
}
