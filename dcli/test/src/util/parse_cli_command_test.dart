@Timeout(Duration(seconds: 600))
library;

import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/parse_cli_command.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('ParseCLICommand', () {
    test('empty string', () {
      const test = '';

      expect(
        () => ParsedCliCommand(test, pwd),
        throwsA(isA<InvalidArgumentException>()),
      );
    });
    test('a', () {
      const test = 'a';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(<String>[]));
    });

    test('ab', () {
      const test = 'ab';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('ab'));
    });

    test('a b c', () {
      const test = 'a b c';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c']));
    });

    test('aa bb cc', () {
      const test = 'aa bb cc';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('aa'));
      expect(parsed.args, equals(['bb', 'cc']));
    });

    test('a  b  c', () {
      const test = 'a  b  c';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c']));
    });

    test('a  "b"  "c1"', () {
      const test = 'a  "b"  "c1"';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('a'));
      expect(parsed.args, equals(['b', 'c1']));
    });

    test('git log --pretty=format:"%s" v1.0.45', () {
      const test = 'git log --pretty=format:"%s" v1.0.45';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('git'));
      expect(parsed.args, equals(['log', '--pretty=format:%s', 'v1.0.45']));
    });

    test('git commit --message="foo bar"', () {
      const test = 'git commit --message="foo bar" "me"';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('git'));
      expect(parsed.args, equals(['commit', '--message=foo bar', 'me']));
    });

    test('escape git commit --message=foo^ bar', () {
      const test = 'git commit --message=foo^ bar';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('git'));
      expect(parsed.args, equals(['commit', '--message=foo bar']));
    });

    test('double escape git commit --message=foo^^bar', () {
      const test = 'git commit --message=foo^^bar';
      final parsed = ParsedCliCommand(test, pwd);

      expect(parsed.cmd, equals('git'));
      expect(parsed.args, equals(['commit', '--message=foo^bar']));
    });

    test('ssh with quoted args', () {
      const command =
          'mkdir -p  /tmp/etc/openvpn; sudo cp -R /etc/openvpn/* /tmp/etc/openvpn';

      // ignore: unnecessary_statements

      final cmdArgs = <String>[]
        ..clear()
        ..add('-t')
        ..add('bilby.clouddialer.com.au')
        ..add("'echo abc123 | sudo -S  $command'");

      final parsed = ParsedCliCommand.fromParsed('ssh', cmdArgs, pwd);

      expect(parsed.cmd, equals('ssh'));
      expect(
        parsed.args,
        equals([
          '-t',
          'bilby.clouddialer.com.au',
          'echo abc123 | sudo -S  $command'
        ]),
      );
    });

    test('ssh with quoted args', () {
      const command =
          '''op-scp.dart 'onepub:"OnePub.dev Logo – reversed FA.png"' .''';

      final parsed = ParsedCliCommand(command, pwd);
      expect(parsed.cmd, equals('op-scp.dart'));

      expect(
        parsed.args,
        equals([
          'onepub:"OnePub.dev Logo – reversed FA.png"',
          '.',
        ]),
      );
    });

    test('ssh with escaped quoted args', () {
      const command =
          '''op-scp.dart "onepub:^"OnePub.dev Logo – reversed FA.png^"" .''';

      final parsed = ParsedCliCommand(command, pwd);
      expect(parsed.cmd, equals('op-scp.dart'));

      expect(
        parsed.args,
        equals([
          'onepub:"OnePub.dev Logo – reversed FA.png"',
          '.',
        ]),
      );
    });

    test('nested quotes with escaped quoted args', () {
      var from = 'onepub:"OnePub.dev Logo – reversed FA.png"';
      var to = '.';

      from = from.replaceAll('"', '^"');
      to = to.replaceAll('"', '^"');

      final command = 'gcloud compute scp --zone=us-west1-b '
          '--project=onepub-dev "$from" "$to"';

      final parsed = ParsedCliCommand(command, pwd);
      expect(parsed.cmd, equals('gcloud'));

      expect(
        parsed.args,
        equals([
          'compute',
          'scp',
          '--zone=us-west1-b',
          '--project=onepub-dev',
          'onepub:"OnePub.dev Logo – reversed FA.png"',
          '.',
        ]),
      );
    });
  });

  group('Glob expansion', () {
    test('No expansion', () {
// var cmd = 'docker run   --network host   dcli:docker_dev_cli   -it --volume $HOME:/me --entrypoint /bin/bash';
    });
  });

  test(
    'linux/macos',
    () async {
      await withTempDir((fsRoot) async {
        final fs = TestDirectoryTree(fsRoot);
        final parsed = ParsedCliCommand('ls *.jpg *.png', fs.top);

        expect(parsed.cmd, equals('ls'));

        expect(
          parsed.args,
          unorderedEquals(<String>[
            'fred.jpg',
            'one.jpg',
            'fred.png',
          ]),
        );
      });
    },
    onPlatform: <String, Skip>{
      'windows': const Skip("Powershell doesn't do glob expansion")
    },
  );

  test(
    '.*',
    () async {
      await withTempDir((fsRoot) async {
        final fs = TestDirectoryTree(fsRoot);
        final parsed = ParsedCliCommand('ls .*', fs.top);

        expect(parsed.cmd, equals('ls'));

        expect(parsed.args, unorderedEquals(<String>['.hidden', '.two.txt']));
      });
    },
    onPlatform: <String, Skip>{
      'windows': const Skip("Powershell doesn't do glob expansion")
    },
  );

  test(
    'valid/.*',
    () async {
      await withTempDir((fsRoot) async {
        final fs = TestDirectoryTree(fsRoot);

        final parsed = ParsedCliCommand('ls middle/.*', fs.top);

        expect(parsed.cmd, equals('ls'));

        expect(
          parsed.args,
          unorderedEquals(<String>['middle/.hidden', 'middle/.four.txt']),
        );
      });
    },
    onPlatform: <String, Skip>{
      'windows': const Skip("Powershell doesn't do glob expansion")
    },
  );

  test(
    'alternate working directory',
    () async {
      await withTempDir((fsRoot) async {
        final fs = TestDirectoryTree(fsRoot);

        final parsed = ParsedCliCommand('ls *.txt *.jpg', fs.middle);

        expect(parsed.cmd, equals('ls'));

        expect(
          parsed.args,
          unorderedEquals(<String>[
            'three.txt',
            'four.txt',
            'two.jpg',
          ]),
        );
      });
    },
    onPlatform: <String, Skip>{
      'windows': const Skip("Powershell doesn't do glob expansion"),
    },
  );

  test('valid non-local path', () async {
    await withTempDir((fsRoot) async {
      final fs = TestDirectoryTree(fsRoot);

      final parsed = ParsedCliCommand('ls middle/*.txt', fs.top);

      expect(parsed.cmd, equals('ls'));

      if (core.Settings().isWindows) {
        expect(parsed.args, unorderedEquals(<String>['middle/*.txt']));
      } else {
        expect(
          parsed.args,
          unorderedEquals(<String>[
            'middle/three.txt',
            'middle/four.txt',
          ]),
        );
      }
    });
  });

  test('invalid absolute path/*', () async {
    await withTempDir((fsRoot) async {
      final fs = TestDirectoryTree(fsRoot);

      final parsed = ParsedCliCommand('ls /git/dcli/*', fs.top);

      expect(parsed.cmd, equals('ls'));
      expect(parsed.args, equals(['/git/dcli/*']));
    });
  });

  test('valid absolute path/*', () async {
    await withTempDir((fsRoot) async {
      final fs = TestDirectoryTree(fsRoot);

      final parsed = ParsedCliCommand('ls ${join(fs.top, '*.txt')}', fs.middle);

      expect(parsed.cmd, equals('ls'));

      if (core.Settings().isWindows) {
        expect(parsed.args, unorderedEquals(<String>[join(fs.top, '*.txt')]));
      } else {
        expect(
          parsed.args,
          unorderedEquals(
            <String>[join(fs.top, 'one.txt'), join(fs.top, 'two.txt')],
          ),
        );
      }
    });
  });

  test(
    'windows',
    () async {
      await withTempDir((fsRoot) async {
        final fs = TestDirectoryTree(fsRoot);

        final parsed = ParsedCliCommand('ls *.jpg *.png', fs.top);

        expect(parsed.cmd, equals('ls'));

        expect(parsed.args, equals(['*.jpg', '*.png']));
      });
    },
    onPlatform: <String, Skip>{
      'posix': const Skip('posix systems do glob expansion'),
    },
  );

  test('Quote handling', () {
    const cmd = '''
docker 
      exec
      -it 
      XXXXXX
      mysql
      --user=root
      --password=password
      --host=slayer
      --port=3306
      -e
      "CREATE USER 'me'@'localhost' IDENTIFIED BY 'mypassword'; GRANT ALL ON dcli.* TO 'me'@'slayer';"
      ''';

    final parsed = ParsedCliCommand(cmd.replaceAll('\n', ' '), pwd);

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
        '''CREATE USER 'me'@'localhost' IDENTIFIED BY 'mypassword'; GRANT ALL ON dcli.* TO 'me'@'slayer';''',
      ),
    );
  });
}
