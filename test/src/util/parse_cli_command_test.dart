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

  test('Quote handling', () {
    var cmd = '''docker 
      exec
      -it 
      XXXXXX
      mysql
      --user=root
      --password=password
      --host=slayer
      --port=3306
      -e
      "CREATE USER 'me'@'localhost' IDENTIFIED BY 'mypassword'; GRANT ALL ON dshell.* TO 'me'@'slayer';"
      ''';

    var parsed = ParsedCliCommand(cmd.replaceAll('\n', ' '), pwd);

    expect(parsed.cmd, equals('docker'));
    expect(parsed.args.length, equals(10));
    expect(parsed.args[0], equals('''exec'''));
    expect(parsed.args[1], equals('''-it'''));
    expect(parsed.args[2], equals('''XXXXXX'''));
    expect(parsed.args[3], equals('''mysql'''));
    expect(parsed.args[4], equals('''--user=root'''));
    expect(parsed.args[5], equals('''--password=password'''));
    expect(parsed.args[6], equals('''--host=slayer'''));
    expect(parsed.args[7], equals('''--port=3306'''));
    expect(parsed.args[8], equals('''-e'''));
    expect(
        parsed.args[9],
        equals(
            '''CREATE USER 'me'@'localhost' IDENTIFIED BY 'mypassword'; GRANT ALL ON dshell.* TO 'me'@'slayer';'''));
  });
}
