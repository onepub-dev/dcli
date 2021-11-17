@Timeout(Duration(minutes: 5))
import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:dcli/windows.dart';
import 'package:test/test.dart';

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
    skip: !Platform.isWindows,
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
    skip: !Platform.isWindows,
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
    skip: !Platform.isLinux,
  );
}
