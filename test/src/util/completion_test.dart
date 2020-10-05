@Timeout(Duration(seconds: 600))
import 'dart:io';

import 'package:dcli/src/util/completion.dart';
import 'package:test/test.dart';

void main() {
  test('completion ...', () async {
    Directory.current = '/home/bsutton/git/dscripts';
    print(completionExpandScripts('',
        workingDirectory: '/home/bsutton/git/dscripts'));

    Directory.current = '/home/bsutton/git';
    print(completionExpandScripts('dscripts/d',
        workingDirectory: '/home/bsutton/git'));
  });
}
