import 'dart:io';

import 'package:dshell/script/flags.dart';
import 'package:dshell/util/dshell_exception.dart';
import 'package:dshell/util/stack_list.dart';
import 'package:path/path.dart' as p;

/// Holds all of the global settings for dshell
class Settings {
  static Settings _self;
  static const templateDir = "templates";

  InternalSettings _settings = InternalSettings();

  /// The directory where we store all of dshell's
  /// configuration files such as the cache.
  String _configRootPath;

  String get configRootPath => _configRootPath;

  String get templatePath => p.join(configRootPath, templateDir);

  final String appname;

  final String version;

  // the list of flags selected via the cli.
  Map<String, Flag> _selectedFlags = Map();

  List<Flag> get selectedFlags => _selectedFlags.values.toList();

  bool get isVerbose => isFlagSet(VerboseFlag());

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

  /// returns the state of the debug options
  /// True if debugging is on.
  /// ```dart
  /// Settings().debug_on
  /// ```
  bool get debug_on => _settings.debug_on;

  /// Returns true if the directory stack
  /// maintained by [push] and [pop] has
  /// is currently empty.
  /// ```dart
  /// Settings().isStackEmpty
  /// ```
  bool get isStackEmpty => _settings.isStackEmpty;

  /// Set [debug_on] to true to have the system log additional information
  /// about each command that executes.
  /// [debug_on] defaults to false.
  ///
  /// ```dart
  /// Settings().debug_on = true;
  /// ```
  set debug_on(bool on) => _settings.debug_on = on;
}

///
/// Internal class that Stores a number of global settings used to
/// control the behaviour of the package.
///
class InternalSettings {
  static InternalSettings _self = InternalSettings._internal();

  StackList<Directory> directoryStack = StackList();

  bool _debug_on = false;

  bool get debug_on => _debug_on;

  bool get isStackEmpty => directoryStack.isEmpty;

  set debug_on(bool on) => _debug_on = on;

  factory InternalSettings() {
    return _self;
  }

  InternalSettings._internal();

  /// Internal methods used to maintain the directory stack
  /// DO NOT use this method directly instead use the [push] command.
  void push(Directory current) => directoryStack.push(current);

  /// Internal methods used to maintain the directory stack
  /// DO NOT use this method directly instead use the [pop] command.
  Directory pop() => directoryStack.pop();
}
