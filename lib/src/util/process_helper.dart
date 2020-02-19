import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dshell/dshell.dart';
import 'package:dshell/src/util/runnable_process.dart';

///
/// EXPERIMENTAL
///
/// This class is likely to change/replaced.
class ProcessHelper {
  static final ProcessHelper _self = ProcessHelper._internal();

  factory ProcessHelper() {
    return _self;
  }

  ProcessHelper._internal();

  String getPIDName(int pid) {
    if (Platform.isWindows) {
      return _getWindowsPidName(pid);
    } else {
      return _getLinuxPIDName(pid);
    }
  }

  /// Gest the process name for the given pid
  ///
  /// Throws an RunException exception if the name can't
  /// be obtained.
  String _getLinuxPIDName(int pid) {
    String line;

    try {
      line = 'ps -q $pid -o comm='.firstLine;
    } on ProcessException {
      // ps not supported on current OS
      line = 'unknown';
    }
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

    String line;
    try {
      line = 'ps -p $childPid -o ppid='.firstLine;
    } on ProcessException {
      // ps not supported on current OS
      line = '-1';
    }
    parentPid = int.tryParse(line.trim());

    return parentPid;
  }

  bool isRunning(int lpid) {
    if (Platform.isWindows) {
      return _WindowsIsrunning(lpid);
    } else {
      return _LinuxisRunning(lpid);
    }
  }

  bool _WindowsIsrunning(int lpid) {
    for (var details in _getWindowsProcesses()) {
      if (details.pid == lpid) {
        return true;
      }
    }
    return false;
  }

  bool _LinuxisRunning(int lpid) {
    var isRunning = false;

    String line;

    try {
      line = 'ps -q $lpid -o comm='.firstLine;
      if (line != null) {
        isRunning = true;
      }
    } on RunException {
      // ps not supported on current OS
      // we have to assume the process running
    }

    return isRunning;
  }

  /// completely untested as I don't have a windows box.
  String _getWindowsPidName(int lpid) {
    String pidName;
    for (var details in _getWindowsProcesses()) {
      if (lpid == details.pid) {
        pidName = details.processName;
        break;
      }
    }
    return pidName;
  }

  List<PIDDetails> _getWindowsProcesses() {
    var pids = <PIDDetails>[];

    // "wininit.exe","584","Services","0","5,248 K"
    var tasks = 'tasklist /fo csv /nh'.toList();

    var lines = const CsvToListConverter().convert(tasks.join('\r\n'));
    for (var line in lines) {
      var details = PIDDetails();

      details.processName = line[0] as String;
      details.pid = line[1] as int;
      details.memory = line[4] as String;
      details.memoryUnits = line[5] as String;

      pids.add(details);
    }

    return pids;
  }
}

class PIDDetails {
  int pid;
  String processName;
  String memory;
  String memoryUnits;
}
