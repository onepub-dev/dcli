import 'dart:io';

import '../stack_list.dart';

class Settings {
  static Settings _self = Settings._internal();
  InternalSettings _settings = InternalSettings();

  factory Settings() => _self;

  /// returns the state of the debug options
  /// True if debugging is on.
  bool get debug_on => _settings.debug_on;

  /// Returns true if the directory stack
  /// maintained by [push] and [pop] has
  /// is currently empty.
  bool get isStackEmpty => _settings.isStackEmpty;

  /// Set [debug_on] to true to have the system log additional information
  /// about each command that executes.
  /// [debug_on] defaults to false.
  set debug_on(bool on) => _settings.debug_on = on;

  Settings._internal();
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
