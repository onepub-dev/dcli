import 'package:test/test.dart';
import 'package:dshell/dshell.dart';

void main() {
  test('start with progress', () {
    var result = <String>[];
    'echo hi'.start(
      runInShell: true,
      progress: Progress((line) => result.add(line),
          stderr: (line) => result.add(line)),
    );

    expect(result, orderedEquals(<String>['hi']));
  });
}
