import 'package:dshell/src/util/progress.dart';

import 'runnable_process.dart';

class Pipe {
  RunnableProcess lhs;
  RunnableProcess rhs;

  Pipe(this.lhs, this.rhs) {
    lhs.pipeTo(rhs);
  }

  Pipe operator |(String next) {
    var pNext = RunnableProcess(next);
    pNext.start(waitForStart: false);
    return Pipe(rhs, pNext);
  }

  void forEach(LineAction stdout, {LineAction stderr}) {
    var progress = Progress(stdout, stderr: stderr);
    rhs.processUntilExit(progress);
  }

  void get run => rhs
      .processUntilExit(Progress(Progress.devNull, stderr: Progress.devNull));
}
