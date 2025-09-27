/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test(
    'which ...',
    ()  {
      expect(which('ls').path, equals('/usr/bin/ls'));
      expect(which('ls').found, equals(true));
      expect(which('ls').notfound, equals(false));
      expect(which('ls').paths.length, equals(1));
    },
    skip: Settings().isWindows,
  );

  test(
    'which ...',
    ()  {
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
