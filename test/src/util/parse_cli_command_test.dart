@Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/functions/pwd.dart';

import 'package:dshell/src/script/command_line_runner.dart';
import 'package:dshell/src/util/parse_cli_command.dart';
import 'package:test/test.dart';

import 'test_file_system.dart';

void main() {
  group('ParseCLICommand', () {
    test('empty string', () {
      var test = '';

      expect(() => ParsedCliCommand(test, pwd),
          throwsA(TypeMatcher<InvalidArguments>()));
    });
    test('a', () {
      var test = 'a';
      var parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(<String>[]));
    });

    test('ab', () {
      var test = 'ab';
      var parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('ab'));
    });

    test('a b c', () {
      var test = 'a b c';
      var parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c']));
    });

    test('aa bb cc', () {
      var test = 'aa bb cc';
      var parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('aa'));
      expect(parsed.args, equals(['bb', 'cc']));
    });

    test('a  b  c', () {
      var test = 'a  b  c';
      var parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c']));
    });

    test('a  "b"  "c1"', () {
      var test = 'a  "b"  "c1"';
      var parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals([r'b', 'c1']));
    });

    test('git log --pretty=format:"%s" v1.0.45', () {
      var test = 'git log --pretty=format:"%s" v1.0.45';
      var parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('git'));
      expect(parsed.args, equals(['log', '--pretty=format:%s', 'v1.0.45']));
    });

    test('ssh with quoted args', () {
      var command =
          'mkdir -p  /tmp/etc/openvpn; sudo cp -R /etc/openvpn/* /tmp/etc/openvpn';

      var cmdArgs = <String>[];
      cmdArgs.clear();
      cmdArgs.add('-t');
      cmdArgs.add('bilby.clouddialer.com.au');
      cmdArgs.add("'echo abc123 | sudo -S  $command'");

      var parsed = ParsedCliCommand.fromParsed('ssh', cmdArgs, pwd);

      expect(parsed.cmd, equals('ssh'));
      expect(
          parsed.args,
          equals([
            '-t',
            'bilby.clouddialer.com.au',
            'echo abc123 | sudo -S  $command'
          ]));
    });
  });

  group(('Glob expansion'), () {
    test('No expansion', () {
// var cmd = 'docker run   --network host   dshell:docker_dev_cli   -it --volume $HOME:/me --entrypoint /bin/bash';
    });
  });

  test('glob expansion - linux/macos', () {
    TestFileSystem().withinZone((fs) {
      var parsed = ParsedCliCommand('ls *.jpg *.png', fs.top);

      expect(parsed.cmd, equals('ls'));

      expect(
          parsed.args,
          unorderedEquals(<String>[
            'fred.jpg',
            'one.jpg',
            'fred.png',
          ]));
    });
  }, onPlatform: <String, Skip>{
    'windows': Skip("Powershell doesn't do glob expansion")
  });

  test('glob expansion - alternate working directory', () {
    TestFileSystem().withinZone((fs) {
      var parsed = ParsedCliCommand('ls *.txt *.jpg', fs.middle);

      expect(parsed.cmd, equals('ls'));

      expect(
          parsed.args,
          unorderedEquals(<String>[
            'three.txt',
            'four.txt',
            'two.jpg',
          ]));
    });
  }, onPlatform: <String, Skip>{
    'windows': Skip("Powershell doesn't do glob expansion")
  });

  test('glob expansion - windows', () {
    TestFileSystem().withinZone((fs) {
      var parsed = ParsedCliCommand('ls *.jpg *.png', fs.top);

      expect(parsed.cmd, equals('ls'));

      expect(parsed.args, equals(['*.jpg', '*.png']));
    });
  }, onPlatform: <String, Skip>{
    'posix': Skip('posix systems do glob expansion'),
  });
}
