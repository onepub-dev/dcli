import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('wait for ex ...', () async {
    try {
      waitForEx<void>(doAsyncThrow());
    } catch (e) {
      print('stacktrace ${e.stackTrace}');

      // print('terse: ${Chain.current().terse}');
    }
  });
}

Future<void> doAsyncThrow() async {
  throw Exception('oh no');
  //return null;
}
