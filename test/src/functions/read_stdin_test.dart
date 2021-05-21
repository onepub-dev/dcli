@t.Timeout(Duration(seconds: 600))
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';

void main() {
  // can't be run from within vscode as it needs console input.
  t.group('Read from stdin', () {
    t.test('Read and then write ', () {
      readStdin().forEach(print);
    }, skip: true);
  });
}
