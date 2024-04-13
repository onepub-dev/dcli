import 'package:dcli_sdk/src/commands/compile.dart';
import 'package:dcli_sdk/src/util/exceptions.dart';
import 'package:test/test.dart';

void main() {
  test('compile invalid package name', () async {
    // expect(() => range(5, 3),
    // throwsA(predicate((e) => e is ArgumentError && e.message == 'start must be less than stop')));
    expect(
        () => CompileCommand().compilePackage('git/dcli_scripts'),
        throwsA(predicate((e) =>
                e is InvalidCommandArgumentException &&
                e.message
                    .contains('To compile the package git/dcli_scripts it must')

//             ==
//                 '''
// To compile the package git/dcli_scripts it must first be installed.
// Run:
//   dart pub global activate git/dcli_scripts
// '''
            )));
  });
}
