import 'progress.dart';

import 'runnable_process.dart';

/// used to pipe date from one proces to another.
class Pipe {
  final RunnableProcess _lhs;
  final RunnableProcess _rhs;

  ///
  Pipe(this._lhs, this._rhs) {
    _lhs.pipeTo(_rhs);
  }

  ///
  Pipe operator |(String next) {
    final pNext = RunnableProcess.fromCommandLine(next);
    pNext.start(waitForStart: false);
    return Pipe(_rhs, pNext);
  }

  ///
  void forEach(LineAction stdout, {LineAction stderr}) {
    final progress = Progress(stdout, stderr: stderr);
    _rhs.processUntilExit(progress, nothrow: false);
  }

  ///
  List<String> toList() {
    final list = <String>[];

    forEach((line) => list.add(line), stderr: (line) => list.add(line));

    return list;
  }

  // void get run => rhs
  //     .processUntilExit(Progress(Progress.devNull, stderr: Progress.devNull));

  /// pumps data trough the pipe.
  void get run =>
      _rhs.processUntilExit(Progress(print, stderr: print), nothrow: false);
}
