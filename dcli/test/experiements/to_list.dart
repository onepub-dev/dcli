import 'package:dcli/dcli.dart';

void main() {
  final pathTo = DartProject.self.pathToPubSpec;

  // print(red('toList'));
  // print('cat $pathTo'.toList());

  // print(red('start'));
  // 'cat $pathTo'.start();

  print(red('capture'));
  final capture = Progress.capture();
  'cat $pathTo'.start(progress: capture);
  print('list: ${capture.toList()}');
}
