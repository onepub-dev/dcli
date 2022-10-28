/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/windows.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:win32/win32.dart';

void _appendIfAbsent(String newPath) {
  final path = regGetExpandString(HKEY_CURRENT_USER, 'Environment', 'Path');

  if (!path.contains(newPath)) {
    regAppendToPath(newPath);
  }
}

void main() {
  test(
    'setPath',
    () {
      const dartToolDir = r'C:\tools\dart-sdk';

      /// add the dartsdk path to the windows path.
      Env().appendToPATH(join(dartToolDir, 'bin'));
      Env().appendToPATH(PubCache().pathToBin);
      Env().appendToPATH(Settings().pathToDCliBin);

      print(PATH);
      // update the windows registry so the change sticks.
      _appendIfAbsent(join(dartToolDir, 'bin'));
      _appendIfAbsent(PubCache().pathToBin);
      _appendIfAbsent(Settings().pathToDCliBin);

      // 'setx PATH "${PATH.join(Env().delimiterForPATH)}"'.run;
    },
    skip: !core.Settings().isWindows,
  );

  test(
    'PutIfAbsent',
    () {
      const dartToolDir = r'C:\tools\dart-sdk';

      /// add the dartsdk path to the windows path.
      Env().appendToPATH(join(dartToolDir, 'bin'));
      Env().appendToPATH(PubCache().pathToBin);
      Env().appendToPATH(Settings().pathToDCliBin);

      print(PATH);
    },
    skip: !core.Settings().isWindows,
  );

  test(
    'PutIfAbsent',
    () {
      const dartToolDir = '/tools/dart-sdk';

      /// add the dartsdk path to the windows path.
      Env().appendToPATH(join(dartToolDir, 'bin'));
      Env().appendToPATH(PubCache().pathToBin);
      Env().appendToPATH(Settings().pathToDCliBin);

      print(PATH);
    },
    skip: !core.Settings().isLinux,
  );
}
