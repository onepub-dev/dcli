import 'package:dcli_sdk/src/commands/compile.dart';
import 'package:dcli_sdk/src/util/exceptions.dart';
import 'package:test/test.dart';

void main() {
  test('compile invalid package name', () async {
    expect(
        () => CompileCommand().compilePackage('git/dcli_scripts'),
        throwsA(predicate((e) =>
            e is InvalidCommandArgumentException &&
            e.message
                .contains('To compile the package git/dcli_scripts it must'))));
  });
}
