/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test(
    'which ...',
    () async {
      expect(which('ls').path, equals('/usr/bin/ls'));
      expect(which('ls').found, equals(true));
      expect(which('ls').notfound, equals(false));
      expect(which('ls').paths.length, equals(1));
    },
    skip: Settings().isWindows,
  );

  test(
    'which ...',
    () async {
      expect(which('regedit.exe').path,
          equalsIgnoringCase(r'C:\Windows\regedit.exe'));
      expect(which('regedit.exe').found, equals(true));
      expect(which('regedit.exe').notfound, equals(false));
      expect(which('regedit.exe').paths.length, equals(1));

      expect(
        which('regedit').path!.toLowerCase(),
        equals(r'C:\Windows\regedit.exe'.toLowerCase()),
      );
    },
    skip: !Settings().isWindows,
  );

  test('progress', () async {
    final controller = StreamController<String>();
    controller.stream.listen((line) => print('listen $line'));
    which('dart', progress: controller.sink, verbose: true).found;
    print('done');
    await controller.close();
  });
}
