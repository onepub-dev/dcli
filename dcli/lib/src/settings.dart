import 'dart:io';

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import '../dcli.dart';
import 'script/flags.dart';
import 'version/version.g.dart';

/// Holds all of the global settings for DCli
/// including dcli paths and any global
/// flags passed on the command line to DCli.
///
class Settings {
  /// Returns a singleton providing
  /// access to DCli settings.
  factory Settings() => _self ??= Settings._init();

  Settings._init({
    this.appname = 'dcli',
  }) {
    version = packageVersion;
  }

  static Settings? _self;

  /// The directory name of the DCli templates.
  static const templateDir = 'template';

  final InternalSettings _settings = InternalSettings();

  /// The name of the DCli app. This will
  /// always be 'dcli'.
  final String appname;

  /// The DCli version you are running
  String? version;

  final _selectedFlags = <String, Flag>{};

  String? _dcliPath;

  /// The name of the dcli settings directory.
  /// This is .dcli.
  String dcliDir = '.dcli';

  String? _dcliBinPath;

  String? _scriptPath;

  /// The absolute path to the dcli script which
  /// is currently running.
  @Deprecated('Use Script.current.pathToScript')
  String get pathToScript {
    _scriptPath ??= DartScript.current.pathToScript;
    return _scriptPath!;
  }

  /// Used when unit testing and we are re-using
  /// the current process.
  @visibleForTesting
  static void reset() {
    _self = Settings._init();
    _self!.selectedFlags.clear();
    _self!._dcliPath = null;
    _self!._dcliBinPath = null;
  }

  /// The directory where we store all of dcli's
  /// configuration files.
  /// This will normally be ~/.dcli
  String get pathToDCli => _dcliPath ??= truepath(p.join(HOME, dcliDir));

  /// When you run dcli compile -i <script> the compiled exe
  /// is moved to this path.
  /// The dcliBinPath is added to the OS's path
  /// allowing the installed scripts to be run from anywhere.
  /// This will normally be ~/.dcli/bin
  String get pathToDCliBin =>
      _dcliBinPath ??= truepath(p.join(HOME, dcliDir, 'bin'));

  /// path to the dcli template directory.
  @Deprecated('Use pathToTemplateScript or pathToTemplateProject')
  String get pathToTemplate => p.join(pathToDCli, templateDir);

  /// path to the dcli template directory.
  String get pathToTemplateProject =>
      p.join(pathToDCli, templateDir, 'project');

  /// Path to the directory where users can store their own custom templates
  String get pathToTemplateProjectCustom =>
      p.join(pathToDCli, templateDir, 'project', 'custom');

  /// path to the dcli template directory.
  String get pathToTemplateScript => p.join(pathToDCli, templateDir, 'script');

  /// Path to the directory where users can store their own custom templates
  String get pathToTemplateScriptCustom =>
      p.join(pathToDCli, templateDir, 'script', 'custom');

  /// the list of global flags selected via the cli when dcli
  /// was started.
  List<Flag> get selectedFlags => _selectedFlags.values.toList();

  /// returns true if the -v (verbose) flag was set on the
  /// dcli command line.
  /// e.g.
  /// dcli -v clean
  bool get isVerbose => core.Settings().isVerbose;

  Logger get logger => Logger('dcli');

  /// Turns on verbose logging.
  void setVerbose({required bool enabled}) {
    core.Settings().setVerbose(enabled: enabled);
  }

  /// Logs a message to the console if the verbose
  /// settings are on.
  void verbose(String? string) {
    core.Settings().verbose(string);
  }

  /// we consider dcli installed if the ~/.dcli directory
  /// exists.
  bool get isInstalled => exists(installCompletedIndicator);

  /// returns the path to the file that we use to indicated
  /// that the install completed succesfully.
  String get installCompletedIndicator => join(pathToDCli, 'install_completed');

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
  bool isFlagSet(Flag flag) => _selectedFlags.containsValue(flag);

  /// A method to set a global flag.
  void setFlag(Flag flag) {
    _selectedFlags[flag.name] = flag;
  }

  /// Returns true if the directory stack
  /// maintained by push and pop has
  /// is currently empty.
  /// ```dart
  /// Settings().isStackEmpty
  /// ```
  @Deprecated('use join')
  bool get isStackEmpty => _settings._isStackEmpty;

  /// Used for unit testing dcli.
  /// Please look away.
  // ignore: avoid_setters_without_getters
  static set mock(Settings mockSettings) {
    _self = mockSettings;
  }
}

///
/// If [Settings.isVerbose] is true then
/// this method will call [callback] to
/// get a String which will be logged to the
/// console or the log file set via the verbose command line
/// option.
///
/// This method is more efficient than calling [Settings.verbose]
/// as it will only build the string if verbose is enabled.
///
/// ```dart
/// verbose(() => 'Log the users name $user');
///
void verbose(String Function() callback) {
  if (Settings().isVerbose) {
    Settings().verbose(callback());
  }
}

///
/// Internal class that Stores a number of global settings used to
/// control the behaviour of the package.
///
class InternalSettings {
  ///
  factory InternalSettings() => _self;

  InternalSettings._internal();

  static final InternalSettings _self = InternalSettings._internal();

  final _directoryStack = core.StackList<Directory>();

  bool get _isStackEmpty => _directoryStack.isEmpty;

  /// Internal methods used to maintain the directory stack
  /// DO NOT use this method directly instead use the [push] command.
  void push(Directory current) => _directoryStack.push(current);

  /// Internal methods used to maintain the directory stack
  /// DO NOT use this method directly instead use the [pop] command.
  Directory pop() => _directoryStack.pop();
}
