import 'dart:io';

import '../../../dcli.dart';
import '../../util/completion.dart';
import '../../util/format.dart';
import '../../util/pub_cache.dart';
import '../../util/truepath.dart';
import '../command_line_runner.dart';
import '../dart_sdk.dart';
import '../flags.dart';
import '../script.dart';
import 'commands.dart';

/// implementst the 'doctor' command
class DoctorCommand extends Command {
  static const String _commandName = 'doctor';

  ///
  DoctorCommand() : super(_commandName);

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var showScriptDetails = false;

    Script script;
    if (subarguments.length == 1) {
      showScriptDetails = true;
      var scriptPath = subarguments[0];
      Script.validate(scriptPath);
      script = Script.fromFile(scriptPath);
    }
    if (subarguments.length > 1) {
      throw InvalidArguments(
          "'dcli doctor' takes zero or one arguments. Found $subarguments");
    }

    _colprint(['DCli version', '${Settings().version}']);
    print('');

    printPlatform();
    print('');

    printExePaths();
    print('');

    printPackageConfig();
    print('');

    printPATH();
    print('');

    printShell();
    print('');

    printDartLocations();
    print('');

    printPermissions();
    print('');

    if (showScriptDetails) {
      script.doctor;
    }
    return 0;
  }

  void printDartLocations() {
    print('Dart location(s)');
    which('dart').forEach((line) => _colprint(['', line]));
  }

  void printPermissions() {
    print('Permissions');
    _showPermissions('HOME', HOME);
    _showPermissions('.dcli', Settings().pathToDCli);
    _showPermissions('cache', Settings().pathToDCliCache);

    _showPermissions('templates', Settings().pathToTemplate);
  }

  void printShell() {
    _colprint([r'$SHELL', '${env['SHELL']}']);

    var shell = Shell.current;
    _colprint(['Detected SHELL', '${shell.name}']);

    if (shell.hasStartScript) {
      var startScriptPath = shell.pathToStartScript;
      if (startScriptPath == null) {
        _colprint(['Shell Start Script', '${privatePath(startScriptPath)}']);
      } else {
        _colprint(['Shell Start Script', 'Not Found']);
      }
    } else {
      _colprint(['Shell Start Script', 'Not supported by shell']);
    }
  }

  void printPATH() {
    print('PATH');
    for (var path in PATH) {
      _colprint(['', privatePath(path)]);
    }
  }

  void printPackageConfig() {
    if (Platform.packageConfig == null) {
      _colprint(['Package Config', 'Not Passed']);
    } else {
      _colprint(['Package Config', '${privatePath(Platform.packageConfig)}']);
    }
  }

  void printExePaths() {
    var dcliPath = which('dcli').first;
    _colprint([
      'dcli path',
      '${dcliPath == null ? 'Not found' : privatePath(dcliPath)}'
    ]);
    _colprint(['dart exe path', '${privatePath(DartSdk().pathToDartExe)}']);
    var dartPath = which(DartSdk.dartExeName, first: true).first;
    _colprint([
      'dart path',
      '${privatePath(DartSdk().pathToDartExe)}',
      'which: ${privatePath(dartPath)}'
    ]);
    var dart2NativePath = which(DartSdk.dart2NativeExeName, first: true).first;

    if (dart2NativePath != null) {
      _colprint([
        'dart2Native path',
        '${privatePath(DartSdk().dart2NativePath)}',
        'which: ${privatePath(dart2NativePath)}'
      ]);
    } else {
      _colprint([
        'dart2Native path',
        'Not Found',
      ]);
    }
    print('');
    var pubPath = which(DartSdk.pubExeName, first: true).first;

    if (pubPath != null) {
      _colprint([
        'pub path',
        '${privatePath(DartSdk().pathToPubExe)}',
        'which: ${privatePath(pubPath)}'
      ]);
      _colprint(['Pub cache', '${privatePath(PubCache().pathTo)}']);
    } else {
      _colprint([
        'pub path',
        'Not Found',
      ]);
    }
  }

  void printPlatform() {
    _colprint(['OS', '${Platform.operatingSystem}']);
    print(Format.row(['OS Version', '${Platform.operatingSystemVersion}'],
        widths: [17, -1]));
    _colprint(['Path separator', '${Platform.pathSeparator}']);
    print('');
    _colprint(['dart version', '${DartSdk().version}']);
  }

  void _colprint(List<String> cols) {
    //cols[0] = green(cols[0]);
    print(Format.row(cols, widths: [17, 55], delimiter: ' '));
  }

  @override
  String description() =>
      """Running 'dcli doctor' provides diagnostic information on your install 
   and optionally a specific script.""";

  @override
  String usage() => 'doctor [<script path.dart>]';

  @override
  List<String> completion(String word) {
    return completionExpandScripts(word);
  }

  void _showPermissions(String label, String path) {
    if (exists(path)) {
      var fstat = stat(path);

      var owner = _Owner(path);

      label = label.padRight(20);

      var username = Shell.current.loggedInUser;
      if (username != null) {
        print(Format.row([
          '$label',
          '${fstat.modeString()}',
          '<user>:${(owner.group == owner.user ? '<user>' : owner.group)}',
          '${privatePath(path)} '
        ], widths: [
          17,
          9,
          16,
          -1
        ], alignments: [
          TableAlignment.left,
          TableAlignment.left,
          TableAlignment.middle,
          TableAlignment.left
        ]));
      }
    } else {
      _colprint(['$label', '${privatePath(path)} does not exist']);
    }
  }

  @override
  List<Flag> flags() {
    return [];
  }
}

class _Owner {
  String user;
  String group;

  _Owner(String path) {
    if (Settings().isWindows) {
      user = 'Unknown';
      group = 'Unknown';
    } else {
      var lsLine = 'ls -alFd $path'.firstLine;

      if (lsLine == null) {
        throw DCliException('No file/directory matched ${absolute(path)}');
      }

      var parts = lsLine.split(' ');
      user = parts[2];
      group = parts[3];
    }
  }

  @override
  String toString() {
    return '$user:$group';
  }
}
