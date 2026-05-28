/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:scope/scope.dart';
import 'package:stack_trace/stack_trace.dart';

import 'version/version.g.dart';

/// Holds all of the global settings for DCli
/// including dcli paths and any global
/// flags passed on the command line to DCli.
///
class Settings {
  static var scopeKey = const ScopeKey<Settings>();

  static Settings? _self;

  /// The directory name of the DCli templates.
  static const templateDir = 'template';

  /// The name of the DCli app. This will
  /// always be 'dcli'.
  static const dcliAppName = 'dcli';

  /// The DCli version you are running
  String? version;

  String? _dcliPath;

  /// The name of the dcli settings directory.
  /// This is .dcli.
  var dcliDir = '.dcli';

  String? _dcliBinPath;

  /// Returns a singleton providing
  /// access to DCli settings.
  /// @Throwing(MissingDependencyException)
  factory Settings() {
    if (Scope.hasScopeKey(scopeKey)) {
      return Scope.use(scopeKey);
    } else {
      return _self ??= Settings._internal();
    }
  }

  /// To use this method create a [Scope] and inject this
  /// as a value into the scope.
  factory Settings.forScope() => Settings._internal();

  Settings._internal() {
    version = packageVersion;
  }

  /// True if you are running on a Mac.
  bool get isMacOS => core.Settings().isMacOS;

  /// True if you are running on a Linux system.
  bool get isLinux => core.Settings().isLinux;

  /// True if you are running on a Window system.
  bool get isWindows => core.Settings().isWindows;

  /// The directory where we store all of dcli's
  /// configuration files.
  /// This will normally be ~/.dcli
  /// @Throwing(ArgumentError)
  String get pathToDCli =>
      _dcliPath ??= core.truepath(p.join(core.HOME, dcliDir));

  /// When you run dcli compile -i `<script>` the compiled exe
  /// is moved to this path.
  ///
  /// The dcliBinPath is added to the OS's path
  /// allowing the installed scripts to be run from anywhere.
  /// This will normally be ~/.dcli/bin
  /// @Throwing(ArgumentError)
  String get pathToDCliBin =>
      _dcliBinPath ??= core.truepath(p.join(core.HOME, dcliDir, 'bin'));

  /// path to the dcli template directory.
  /// @Throwing(ArgumentError)
  String get pathToTemplateProject =>
      p.join(pathToDCli, templateDir, 'project');

  /// Path to the directory where users can store their own custom templates
  /// @Throwing(ArgumentError)
  String get pathToTemplateProjectCustom =>
      p.join(pathToDCli, templateDir, 'project', 'custom');

  /// path to the dcli template directory.
  /// @Throwing(ArgumentError)
  String get pathToTemplateScript => p.join(pathToDCli, templateDir, 'script');

  /// Path to the directory where users can store their own custom templates
  /// @Throwing(ArgumentError)
  String get pathToTemplateScriptCustom =>
      p.join(pathToDCli, templateDir, 'script', 'custom');

  /// returns true if the -v (verbose) flag was set on the
  /// dcli command line.
  /// e.g.
  /// dcli -v clean
  bool get isVerbose => core.Settings().isVerbose;

  /// @Throwing(ArgumentError)
  Logger get logger => Logger('dcli');

  /// Turns on verbose logging.
  void setVerbose({required bool enabled}) {
    core.Settings().setVerbose(enabled: enabled);
  }

  /// Logs a message to the console if the verbose
  /// settings are on.
  /// @Throwing(ArgumentError)
  /// @Throwing(FormatException)
  void verbose(String? string) {
    final frame = Trace.current().frames[1];
    core.Settings().verbose(string, frame: frame);
  }

  /// we consider dcli installed if the ~/.dcli directory
  /// exists.
  /// @Throwing(ArgumentError)
  bool get isInstalled => core.exists(installCompletedIndicator);

  /// returns the path to the file that we use to indicated
  /// that the install completed succesfully.
  /// @Throwing(ArgumentError)
  String get installCompletedIndicator => join(pathToDCli, 'install_completed');

  /// Used for unit testing dcli.
  /// Please look away.
  // ignore: avoid_setters_without_getters
  static set mock(Settings mockSettings) {
    _self = mockSettings;
  }
}
