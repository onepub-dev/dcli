import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import '../dshell.dart';
import 'functions/env.dart';
import 'script/flags.dart';
import 'util/stack_list.dart';
import 'version/version.g.dart';

/// Holds all of the global settings for DShell
/// including dshell paths and any global
/// flags passed on the command line to DShell.
///
class Settings {
  static Settings _self;

  /// The directory name of the DShell templates.
  static const templateDir = 'templates';

  /// The directory name of the DShell cache.
  static const dshellCacheDir = 'cache';

  final InternalSettings _settings = InternalSettings();

  /// The name of the DShell app. This will
  /// always be 'dshell'.
  final String appname;

  /// The DShell version you are running
  String version;

  final _selectedFlags = <String, Flag>{};

  String _dshellPath;

  /// The name of the dshell settings directory.
  /// This is .dshell.
  String dshellDir = '.dshell';

  String _dshellBinPath;

  String _scriptPath;

  /// The absolute path to the dshell script which
  /// is currently running.
  String get scriptPath {
    if (_scriptPath == null) {
      var actual = Platform.script.toFilePath();
      if (isWithin(dshellCachePath, actual)) {
        // This is a script being run from a virtual project so we
        // need to reconstruct is original path.

        // strip of the cache prefix
        var rel = join(rootPath, relative(actual, from: dshellCachePath));
        //.dshell/cache/home/bsutton/git/dshell/tool/activate_local.project/activate_local.dart

        // now remove the virtual project directory
        _scriptPath = join(dirname(dirname(rel)), basename(rel));
      } else {
        _scriptPath = actual;
      }
    }

    return _scriptPath;
  }

  /// This is an internal function called by the run
  /// command and you should NOT be calling it!
  set scriptPath(String scriptPath) {
    _scriptPath = scriptPath;
  }

  /// Used when unit testing and we are re-using
  /// the current process.
  static void reset() {
    _self = Settings.init();
    _self.selectedFlags.clear();
    _self._dshellPath = null;
    _self._dshellBinPath = null;
  }

  /// The directory where we store all of dshell's
  /// configuration files such as the cache.
  /// This will normally be ~/.dshell
  String get dshellPath {
    _dshellPath ??= p.absolute(p.join(HOME, dshellDir));
    return _dshellPath;
  }

  /// When you run dshell compile -i <script> the compiled exe
  /// is moved to this path.
  /// The dshellBinPath is added to the OS's path
  /// allowing the installed scripts to be run from anywhere.
  /// This will normally be ~/.dshell/bin
  String get dshellBinPath {
    // var st = StackTraceImpl();

    // print('dshellBinPath current: ${_dshellBinPath}');
    // print(st.formatStackTrace());
    _dshellBinPath ??= p.absolute(p.join(HOME, dshellDir, 'bin'));

    return _dshellBinPath;
  }

  /// path to the dshell template directory.
  String get templatePath => p.join(dshellPath, templateDir);

  /// Path to the dshell cache directory.
  /// This will normally be ~/.dshell/cache
  String get dshellCachePath => p.join(dshellPath, dshellCacheDir);

  /// the list of global flags selected via the cli when dshell
  /// was started.
  List<Flag> get selectedFlags => _selectedFlags.values.toList();

  /// returns true if the -v (verbose) flag was set on the
  /// dshell command line.
  /// e.g.
  /// dshell -v clean
  bool get isVerbose => isFlagSet(VerboseFlag());

  /// Turns on verbose logging.
  void setVerbose({@required bool enabled}) {
    if (enabled) {
      if (!isVerbose) {
        setFlag(VerboseFlag());
      }
    } else {
      _selectedFlags.remove(VerboseFlag());
    }
  }

  /// Returns a singleton providing
  /// access to DShell settings.
  factory Settings() {
    _self ??= Settings.init();

    return _self;
  }

  /// Used internally be dshell to initialise
  /// the settings.
  ///
  /// DO NOT CALL THIS METHOD!!!
  Settings.init({
    this.appname = 'dshell',
  }) {
    version = packageVersion;
  }

  /// we consider dshell installed if the ~/.dshell directory
  /// exists.
  bool get isInstalled => exists(installCompletedIndicator);

  /// returns the path to the file that we use to indicated
  /// that the install completed succesfully.
  String get installCompletedIndicator => join(dshellPath, 'install_completed');

  /// True if you are running on a Mac.
  /// I'm so sorry.
  bool get isMacOS => Platform.isMacOS;

  /// True if you are running on a Linux system.
  bool get isLinux => Platform.isLinux;

  /// True if you are running on a Window system.
  bool get isWindows => Platform.isWindows;

  /// A method to test with a specific global
  /// flag has been set.
  ///
  /// This is for interal useage.
  bool isFlagSet(Flag flag) {
    return _selectedFlags.containsValue(flag);
  }

  /// A method to set a global flag.
  void setFlag(Flag flag) {
    _selectedFlags[flag.name] = flag;
  }

  /// Returns true if the directory stack
  /// maintained by [push] and [pop] has
  /// is currently empty.
  /// ```dart
  /// Settings().isStackEmpty
  /// ```
  @Deprecated('use join')
  bool get isStackEmpty => _settings._isStackEmpty;

  /// Logs a message to the console if the verbose
  /// settings are on.
  void verbose(String string) {
    if (isVerbose) {
      if (VerboseFlag().hasOption) {
        VerboseFlag().option.append(string);
      } else {
        print(string);
      }
    }
  }

  /// Used for unit testing dshell.
  /// Please look away.
  // ignore: avoid_setters_without_getters
  static set mock(Settings mockSettings) {
    _self = mockSettings;
  }
}

///
/// Internal class that Stores a number of global settings used to
/// control the behaviour of the package.
///
class InternalSettings {
  static final InternalSettings _self = InternalSettings._internal();

  final _directoryStack = StackList<Directory>();

  bool get _isStackEmpty => _directoryStack.isEmpty;

  ///
  factory InternalSettings() {
    return _self;
  }

  InternalSettings._internal();

  /// Internal methods used to maintain the directory stack
  /// DO NOT use this method directly instead use the [push] command.
  void push(Directory current) => _directoryStack.push(current);

  /// Internal methods used to maintain the directory stack
  /// DO NOT use this method directly instead use the [pop] command.
  Directory pop() => _directoryStack.pop();
}
