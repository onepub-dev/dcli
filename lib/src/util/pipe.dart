import 'runnable_process.dart';

class Pipe {
  RunnableProcess lhs;
  RunnableProcess rhs;

  Pipe(this.lhs, this.rhs) {
    lhs.pipeTo(rhs);
  }

  Pipe operator |(String next) {
    var pNext = RunnableProcess(next);
    pNext.start();
    return Pipe(rhs, pNext);
  }

  void forEach(LineAction stdout, {LineAction stderr}) {
    rhs.processUntilExit(stdout, stderr);
  }

  void get run => rhs.processUntilExit(null, null);
}
