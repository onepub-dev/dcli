import 'runnable_process.dart';

class Pipe {
  RunnableProcess lhs;
  RunnableProcess rhs;

  Pipe(this.lhs, this.rhs) {
    lhs.pipeTo(rhs);
  }

  Pipe operator |(String next) {
    RunnableProcess pNext = RunnableProcess(next);
    pNext.start();
    return Pipe(rhs, pNext);
  }

  void forEach(LineAction lineAction) {
    rhs.processUntilExit(lineAction);
  }
}
