import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/script/my_yaml.dart';

import 'script/flags.dart';
import 'util/stack_list.dart';
import 'package:path/path.dart' as p;

import 'functions/env.dart';

/// Holds all of the global settings for dshell
class Settings {
  static Settings _self;
  static const templateDir = 'templates';
  static const cacheDir = 'cache';

  final InternalSettings _settings = InternalSettings();
  final String appname;

  String version;

  final _selectedFlags = <String, Flag>{};

  String _dshellPath;

  String dshellDir = '.dshell';

  String _dshellBinPath;

  /// The directory where we store all of dshell's
  /// configuration files such as the cache.
  String get dshellPath => _dshellPath;

  /// When you run dshell compile -i <script> the script
  /// is moved to this path.
  /// The dshellBinPath is added to the OS's path
  /// allowing the installed scripts to be run from anywhere
  String get dshellBinPath => _dshellBinPath;

  /// path to the dshell template directory.
  String get templatePath => p.join(dshellPath, templateDir);

  /// path to the dshell cache directory.
  String get cachePath => p.join(dshellPath, cacheDir);

  /// the list of flags selected via the cli.
  List<Flag> get selectedFlags => _selectedFlags.values.toList();

  /// returns true if the -v (verbose) flag was set on the
  /// dshell command line.
  /// e.g.
  /// dshell -v clean
  bool get isVerbose => isFlagSet(VerboseFlag());

  factory Settings() {
    if (_self == null) {
      Settings.init();
    }

    return _self;
  }

  Settings.init({
    this.appname = 'dshell',
  }) {
    var script = Platform.script;

    if (script.isScheme('file')) {
      try {
        var dshellYaml = MyYaml.loadFromFile(
            join(dirname(Platform.script.toFilePath()), '../pubspec.yaml'));

        version = dshellYaml.getValue('version');
      } catch (e) {
        // looks like we can't determine the version
        version = '1.0.28';
      }
    } else {
      // we can't get Platform.script when we are in a unit test
      // so set the version to a default that makes it clear its bogus
      version = '1.x.x-unit-test';
    }

    _self = this;

    var home = HOME;
    _dshellPath = p.absolute(p.join(home, dshellDir));
    _dshellBinPath = p.absolute(p.join(home, dshellDir, 'bin'));
  }

  bool get isMacOS => Platform.isMacOS;

  bool get isLinux => Platform.isLinux;

  bool get isWindows => Platform.isWindows;

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

  static void setMock(Settings mockSettings) {
    _self = mockSettings;
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
