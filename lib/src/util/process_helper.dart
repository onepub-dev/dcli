import 'dart:io';
import 'package:csv/csv.dart';
import '../../dshell.dart';
import 'runnable_process.dart';

///
/// EXPERIMENTAL
///
/// This class is likely to change/replaced.
class ProcessHelper {
  static final ProcessHelper _self = ProcessHelper._internal();

  ///
  factory ProcessHelper() {
    return _self;
  }

  ProcessHelper._internal();

  /// returns the name of the process for the given pid.
  String getProcessName(int pid) {
    if (Platform.isWindows) {
      return _getWindowsProcessName(pid);
    } else {
      return _getLinuxProcessName(pid);
    }
  }

  /// Gest the process name for the given pid
  ///
  /// Throws an RunException exception if the name can't
  /// be obtained.
  String _getLinuxProcessName(int pid) {
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
    if (Platform.isWindows) {
      return _windowsGetParentPid(childPid);
    } else {
      return _linuxGetParentPID(childPid);
    }
  }

  /// returns true if the given [pid] is still running.
  bool isRunning(int pid) {
    if (Platform.isWindows) {
      return _windowsIsrunning(pid);
    } else {
      return _linuxisRunning(pid);
    }
  }

  int _linuxGetParentPID(int childPid) {
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

  int _windowsGetParentPid(int childPid) {
    var parents = _windowsParentProcessList();

    for (var parent in parents) {
      if (parent.processPid == childPid) {
        return parent.parentPid;
      }
    }
    return -1;
  }

  List<_WindowsParentProcess> _windowsParentProcessList() {
    var parents = <_WindowsParentProcess>[];

    var processes = 'wmic process get processid,parentprocessid,executablepath'
        .toList(skipLines: 1);

    for (var process in processes) {
      process = process.trim();
      process = process.replaceAll(RegExp(r'\s+'), ' ');
      // print(process);

      var parts = process.split(' ');
      if (parts.length < 3) {
        // a lot of the lines have blank process ames
        continue;
      }

      // we have to deal with files that contain spaces in their name.
      var exe = parts.sublist(0, parts.length - 3).join(' ');
      var parentPid = int.tryParse(parts[parts.length - 2]);
      var processPid = int.tryParse(parts[parts.length - 1]);

      var parent = _WindowsParentProcess();
      parent.path = exe;
      parent.parentPid = parentPid;
      parent.processPid = processPid;
      parents.add(parent);
    }
    return parents;
  }

  bool _windowsIsrunning(int lpid) {
    for (var details in _getWindowsProcesses()) {
      if (details.pid == lpid) {
        return true;
      }
    }
    return false;
  }

  bool _linuxisRunning(int lpid) {
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
  String _getWindowsProcessName(int lpid) {
    String pidName;
    for (var details in _getWindowsProcesses()) {
      if (lpid == details.pid) {
        pidName = details.processName;
        break;
      }
    }
    return pidName;
  }

  List<_PIDDetails> _getWindowsProcesses() {
    var pids = <_PIDDetails>[];

    // example:
    // "wininit.exe","584","Services","0","5,248 K"
    var tasks = 'tasklist /fo csv /nh'.toList();

    var lines = const CsvToListConverter().convert(tasks.join('\r\n'));
    for (var line in lines) {
      var details = _PIDDetails();

      details.processName = line[0] as String;
      details.pid = int.tryParse(line[1] as String);

      var memparts = (line[4] as String).split(' ');
      details.memory = memparts[0];
      // details.memory can contain 'N/A' in which case their is no units.
      if (memparts.length == 2) {
        details.memoryUnits = memparts[1];
      }

      pids.add(details);
    }

    return pids;
  }
}

class _PIDDetails {
  int pid;
  String processName;
  String memory;
  String memoryUnits;
}

class _WindowsParentProcess {
  String path;
  int parentPid;
  int processPid;
}
