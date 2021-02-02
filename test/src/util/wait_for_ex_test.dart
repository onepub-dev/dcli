import 'package:dcli/dcli.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  test('wait for ex ...', () async {
    try {
      waitForEx<void>(doAsyncThrow());
    } catch (e, st) {
      print('stacktrace $st');

      print('terse: ${Chain.current().terse}');
    }
  });
}

Future<void> doAsyncThrow() async {
  throw Exception('oh no');
  //return null;
}
