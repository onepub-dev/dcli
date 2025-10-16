import '../../../dcli.dart';

void main() {
  print('START');

  try {
    // crashes, and does not release the ports to the isolate
    startFromArgs('false', []);
  } catch (e) {
    print(e);
  }

  print('DONE');
  // Program prints "DONE" immediately but hangs then hangs forever
}
