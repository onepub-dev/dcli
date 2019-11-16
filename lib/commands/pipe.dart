import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dshell/commands/run.dart';

class Pipe {
  Future<Process> lhs;
  Future<Process> rhs;

  Pipe(this.lhs, this.rhs) {
    rhs.then((rhsProcess) {
      lhs.then<void>((lhsProcess) => lhsProcess.stdout.pipe(rhsProcess.stdin));
    });
  }

  Pipe operator |(String next) {
    return Pipe(rhs, Run.start(next));
  }

  void forEach(LineAction lineAction) {
    Completer<bool> done = Completer<bool>();

    rhs.then((process) {
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (lineAction != null) {
          lineAction(line);
        }
      });

      // trap the process finishing
      process.exitCode.then((exitCode) {
        if (exitCode != 0) {
          done.completeError(RunException(
              "The command [rhs.${this.runtimeType}] failed with exitCode: ${exitCode}"));
        } else {
          done.complete(true);
        }
      });
    });
    Run.smartWaitFor<bool>(done.future);
  }
}

class RunableProcess {
  Future<Process> fProcess;
  // The command line used to start the process.
  String cmdLine;
  LineAction lineAction;

  RunableProcess(this.cmdLine, this.lineAction);

  void start() {
    Completer<bool> done = Completer<bool>();

    fProcess.then((process) {
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (lineAction != null) {
          lineAction(line);
        }
      });

      // trap the process finishing
      process.exitCode.then((exitCode) {
        if (exitCode != 0) {
          done.completeError(RunException(
              "The command [rhs.${this.runtimeType}] failed with exitCode: ${exitCode}"));
        } else {
          done.complete(true);
        }
      });
    });
    Run.smartWaitFor<bool>(done.future);
  }
}
