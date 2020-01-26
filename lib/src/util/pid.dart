import 'dart:io' as d;
import 'package:dshell/dshell.dart';

///
/// Provides some conveinence funtions to get access to
/// the scripts pid and its parents pid.
///
/// This class is considered EXPERIMENTAL and is likely to change.
class PID {
  /// Just a convenience function that returns the
  /// current processes PID. You can also obtain this
  /// by just calling the global function [pid] which
  /// is part of dart:io.
  ///
  int get pid => d.pid;

  /// Gets the name of the shell that this dshell
  /// script is running under.
  ///
  /// Note: when you start up dshell there are three processes
  /// involved:
  ///
  /// cli - the cli you started dshell from. This is the shell we will return
  /// sh - the shebang (#!) spawns a [sh] shell which dart is run under.
  /// dart - the dart process
  ///
  /// Your dshell script runs within the above dart process.
  /// See [getShellPID]
  String getShellName() {
    var shellName = 'unknown';
    try {
      shellName = getPIDName(getShellPID());
    } catch (e) {
      /// returns 'unknown'
    }
    return shellName;
  }

  /// Gets the name of the pid that this dshell
  /// script is running under.
  ///
  /// Note: when you start up a dshell script there are three processes
  /// involved:
  ///
  /// cli - the cli you started dshell from. This is the shell pid we will return
  /// sh - the shebang (#!) spawns a [sh] shell which dart is run under.
  /// dart - the dart process
  ///
  /// Your dshell script runs within the above dart process.
  int getShellPID({int childPID}) {
    childPID ??= pid;

    var dartPID = getParentPID(childPID);
    var envPID = getParentPID(dartPID);
    var shellPID = getParentPID(envPID);
    return shellPID;
  }

  /// Gest the process name for the given pid
  ///
  /// Throws an RunException exception if the name can't
  /// be obtained.
  String getPIDName(int pid) {
    String line;

    line = 'ps -q $pid -o comm='.firstLine;
    if (line != null) {
      line = line.trim();
    }

    return line;
  }

  /// Get the PID of the parent
  /// Throws an RunException exception if the name can't
  /// be obtained.
  ///
  int getParentPID(int childPid) {
    int parentPid;

    var line = 'ps -p $childPid -o ppid='.firstLine;
    parentPid = int.tryParse(line.trim());

    return parentPid;
  }
}
