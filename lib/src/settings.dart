import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/script/my_yaml.dart';

import 'script/flags.dart';
import 'util/dshell_exception.dart';
import 'util/stack_list.dart';
import 'package:path/path.dart' as p;

import 'functions/env.dart';

/// Holds all of the global settings for dshell
class Settings {
  static Settings _self;
  static const templateDir = 'templates';
  static const cacheDir = 'cache';

  final InternalSettings _settings = InternalSettings();

  /// The directory where we store all of dshell's
  /// configuration files such as the cache.
  String _dshellPath;

  String get dshellPath => _dshellPath;

  String get templatePath => p.join(dshellPath, templateDir);

  String get cachePath => p.join(dshellPath, cacheDir);

  final String appname;

  String version;

  // the list of flags selected via the cli.
  final _selectedFlags = <String, Flag>{};

  List<Flag> get selectedFlags => _selectedFlags.values.toList();

  bool get isVerbose => isFlagSet(VerboseFlag());

  factory Settings() {
    if (_self == null) {
      Settings.init();
    }

    return _self;
  }

  Settings.init({
    this.appname = 'dshell',
    String dshellDir = '.dshell',
  }) {
    var script = Platform.script;

    if (script.isScheme('file')) {
      var dshellYaml = MyYaml.loadFromFile(
          join(dirname(Platform.script.toFilePath()), '../pubspec.yaml'));

      version = dshellYaml.getValue('version');
    } else {
      // we can't get Platform.script when we are in a unit test
      // so set the version to a default that makes it clear its bogus
      version = '1.x.x-unit-test';
    }

    _self = this;

    var home = userHomePath;
    _dshellPath = p.absolute(p.join(home, dshellDir));
  }

  ///
  /// Gets the path to the users home directory
  /// using the enviornment var HOME
  String get userHomePath {
    var home = env('HOME');

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

  void verbose(String string) {
    if (isVerbose) {
      print(string);
    }
  }
}

///
/// Internal class that Stores a number of global settings used to
/// control the behaviour of the package.
///
class InternalSettings {
  static final InternalSettings _self = InternalSettings._internal();

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
