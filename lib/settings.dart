import 'dart:io';

import 'package:dshell/script/flags.dart';
import 'package:dshell/util/dshell_exception.dart';
import 'package:path/path.dart' as p;

/// Holds all of the global settings for dshell
class Settings {
  static Settings _self;

  /// The directory where we store all of dshell's
  /// configuration files such as the cache.
  String _configRootPath;

  final String appname;

  final String version;

  // the list of flags selected via the cli.
  Map<String, Flag> _selectedFlags = Map();

  List<Flag> get selectedFlags => _selectedFlags.values.toList();

  bool get isVerbose => isFlagSet(VerboseFlag());

  // absolute path to the root of the dshell configuration directory
  // ~.dshell
  String get configRootPath => _configRootPath;

  factory Settings() {
    if (_self == null) {
      Settings.init();
    }

    return _self;
  }

  Settings.init(
      {this.appname = "dshell",
      String configRootPath = ".dshell",
      this.version = "1.0.10"}) {
    _self = this;

    String home = userHomePath;
    _configRootPath = p.absolute(p.join(home, configRootPath));
  }

  ///
  /// Gets the path to the users home directory
  /// using the enviornment var HOME
  String get userHomePath {
    Map<String, String> env = Platform.environment;
    String home = env["HOME"];

    if (home == null) {
      throw DShellException(
          "Unable to find the 'HOME' enviroment variable. Please ensure it is set and try again.");
    }
    return home;
  }

  bool isFlagSet(Flag flag) {
    return _selectedFlags.containsValue(flag);
  }

  void setFlag(Flag flag) {
    _selectedFlags[flag.name] = flag;
  }
}
