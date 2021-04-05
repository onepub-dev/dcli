import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('wait for ex ...', () async {
    try {
      waitForEx<void>(doAsyncThrow());
    // ignore: avoid_catches_without_on_clauses
    } catch (e, st) {
      print('stacktrace $st');

      // print('terse: ${Chain.current().terse}');
    }
  });
}

Future<void> doAsyncThrow() async {
  throw Exception('oh no');
  //return null;
}
