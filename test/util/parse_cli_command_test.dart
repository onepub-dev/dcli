import 'package:dshell/src/script/command_line_runner.dart';
import 'package:dshell/src/util/runnable_process.dart';
import 'package:test/test.dart';

void main() {
  group('ParseCLICommand', () {
    test('empty string', () {
      var test = '';

      expect(() => ParsedCliCommand(test),
          throwsA(TypeMatcher<InvalidArguments>()));
    });
    test('a', () {
      var test = 'a';
      var parsed = ParsedCliCommand(test);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(<String>[]));
    });

    test('ab', () {
      var test = 'ab';
      var parsed = ParsedCliCommand(test);

      expect(parsed.cmd, equals('ab'));
    });

    test('a b c', () {
      var test = 'a b c';
      var parsed = ParsedCliCommand(test);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c']));
    });

    test('aa bb cc', () {
      var test = 'aa bb cc';
      var parsed = ParsedCliCommand(test);

      expect(parsed.cmd, equals('aa'));
      expect(parsed.args, equals(['bb', 'cc']));
    });

    test('a  b  c', () {
      var test = 'a  b  c';
      var parsed = ParsedCliCommand(test);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c']));
    });

    // test(r'a  \ b  c\ 1', () {
    //   var test = r'a  \ b  c\ 1';
    //   var parsed = ParsedCliCommand(test);

    //   expect(parsed.cmd, equals('a'));
    //   expect(parsed.args, equals([r'\ b', r'c\ 1']));
    // });

    // test('a  \ b  c\ 1', () {
    //   var test = r'a  \ b  c\\ 1';
    //   var parsed = ParsedCliCommand(test);

    //   expect(parsed.cmd, equals('a'));
    //   expect(parsed.args, equals([r'\ b', r'c\\', '1']));
    // });

    test('a  "b"  "c1"', () {
      var test = 'a  "b"  "c1"';
      var parsed = ParsedCliCommand(test);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals([r'b', 'c1']));
    });

    test('okular "Introduction to Recursive Programming.pdf"', () {
      var test = 'okular "Introduction to Recursive Programming.pdf"';
      var parsed = ParsedCliCommand(test);

      expect(parsed.cmd, equals('okular'));
      expect(
          parsed.args, equals(['Introduction to Recursive Programming.pdf']));
    });
  });
}
