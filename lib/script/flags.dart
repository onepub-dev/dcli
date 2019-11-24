class Flags {
  static List<Flag> applicationFlags = [HelpFlag(), VerboseFlag()];

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
}

abstract class Flag {
  String _name;

  Flag(this._name);

  String get name => _name;

  String get abbreviation;

  String usage(String appname) => "--$_name | -$abbreviation";

  String description(String appname);
}

class HelpFlag extends Flag {
  static const NAME = "help";

  HelpFlag() : super(NAME);

  String get abbreviation => "h";

  String description(String appname) => "Displays the usage message.";
}

class VerboseFlag extends Flag {
  static const NAME = "verbose";

  VerboseFlag() : super(NAME);

  String get abbreviation => "v";

  String description(String appname) => "If set, turns on verbose logging.";
}
