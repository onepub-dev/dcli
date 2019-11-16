import 'runnable_process.dart';

class Pipe {
  RunnableProcess lhs;
  RunnableProcess rhs;

  Pipe(this.lhs, this.rhs) {
    lhs.pipeTo(rhs);
  }

  Pipe operator |(String next) {
    return Pipe(rhs, RunnableProcess(next));
  }

  void forEach(LineAction lineAction) {
    rhs.processUntilExit();
  }
}
