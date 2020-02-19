import 'package:dshell/src/script/command_line_runner.dart';
import 'package:dshell/src/util/parse_cli_command.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  TestFileSystem();

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

    test('a  "b"  "c1"', () {
      var test = 'a  "b"  "c1"';
      var parsed = ParsedCliCommand(test);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals([r'b', 'c1']));
    });

    test('git log --pretty=format:"%s" v1.0.45', () {
      var test = 'git log --pretty=format:"%s" v1.0.45';
      var parsed = ParsedCliCommand(test);

      expect(parsed.cmd, equals('git'));
      expect(parsed.args, equals(['log', '--pretty=format:%s', 'v1.0.45']));
    });
  });

  group(('Glob expansion'), () {
    test('No expansion', () {

// var cmd = 'docker run   --network host   dshell:docker_dev_cli   -it --volume $HOME:/me --entrypoint /bin/bash';

    });
  });
}
