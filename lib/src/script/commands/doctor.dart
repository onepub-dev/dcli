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
      final scriptPath = subarguments[0];
      Script.validate(scriptPath);
      script = Script.fromFile(scriptPath);
    }
    if (subarguments.length > 1) {
      throw InvalidArguments(
          "'dcli doctor' takes zero or one arguments. Found $subarguments");
    }

    _colprint(['DCli version', Settings().version]);
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
    print('dart location(s)');
    which('dart').paths.forEach((line) => _colprint(['', line]));
  }

  void printPermissions() {
    print('permissions');
    _showPermissions('HOME', HOME);
    _showPermissions('.dcli', Settings().pathToDCli);
    _showPermissions('cache', Settings().pathToDCliCache);

    _showPermissions('templates', Settings().pathToTemplate);
  }

  void printShell() {
    _colprint([r'$SHELL', env['SHELL']]);

    final shell = Shell.current;
    _colprint(['detected SHELL', shell.name]);

    if (shell.hasStartScript) {
      final startScriptPath = shell.pathToStartScript;
      if (startScriptPath == null) {
        _colprint(['shell Start Script', privatePath(startScriptPath)]);
      } else {
        _colprint(['shell Start Script', 'not found']);
      }
    } else {
      _colprint(['shell Start Script', 'not supported by shell']);
    }
  }

  void printPATH() {
    print('PATH');
    for (final path in PATH) {
      _colprint(['', privatePath(path)]);
    }
  }

  void printPackageConfig() {
    if (Platform.packageConfig == null) {
      _colprint(['package Config', 'not passed']);
    } else {
      _colprint(['package Config', privatePath(Platform.packageConfig)]);
    }
  }

  void printExePaths() {
    final dcliPath = which('dcli').path;
    _colprint([
      'dcli path',
      if (dcliPath == null) 'Not found' else privatePath(dcliPath)
    ]);
    _colprint(['dart exe path', privatePath(DartSdk().pathToDartExe)]);
    final dartPath = which(DartSdk.dartExeName).path;
    _colprint([
      'dart path',
      privatePath(DartSdk().pathToDartExe),
      'which: ${privatePath(dartPath)}'
    ]);

    if (DartSdk().useDartCompiler) {
      _colprint(['compiler', "using 'dart compile exe'"]);
    } else {
      _colprint(['compiler', "using 'dart2native'"]);
      final dart2NativePath = which(DartSdk.dart2NativeExeName).path;

      if (dart2NativePath != null) {
        _colprint([
          'dart2Native path',
          privatePath(DartSdk().pathToDartToNativeExe),
          'which: ${privatePath(dart2NativePath)}'
        ]);
      } else {
        _colprint([
          'dart2Native path',
          'Not Found',
        ]);
      }
    }
    print('');
    final pubPath = which(DartSdk.pubExeName).path;

    if (pubPath != null) {
      _colprint([
        'pub path',
        privatePath(DartSdk().pathToPubExe),
        'which: ${privatePath(pubPath)}'
      ]);
      _colprint(['Pub cache', privatePath(PubCache().pathTo)]);
    } else {
      _colprint([
        'pub path',
        'Not Found',
      ]);
    }
  }

  void printPlatform() {
    _colprint(['OS', Platform.operatingSystem]);
    print(Format.row(['OS Version', Platform.operatingSystemVersion],
        widths: [17, -1]));
    _colprint(['path separator', Platform.pathSeparator]);
    print('');
    _colprint(['dart version', DartSdk().version]);
  }

  void _colprint(List<String> cols) {
    //cols[0] = green(cols[0]);
    print(Format.row(cols, widths: [17, 55], delimiter: ' '));
  }

  @override
  String description() => """
Running 'dcli doctor' provides diagnostic information on your install 
   and optionally a specific script.""";

  @override
  String usage() => 'doctor [<script path.dart>]';

  @override
  List<String> completion(String word) {
    return completionExpandScripts(word);
  }

  void _showPermissions(String label, String path) {
    var finallabel = label;
    if (exists(path)) {
      final fstat = stat(path);

      final owner = _Owner(path);

      finallabel = label.padRight(20);

      final username = Shell.current.loggedInUser;
      if (username != null) {
        print(Format.row([
          finallabel,
          fstat.modeString(),
          '<user>:${owner.group == owner.user ? '<user>' : owner.group}',
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
      _colprint([finallabel, '${privatePath(path)} does not exist']);
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
      final lsLine = 'ls -alFd $path'.firstLine;

      if (lsLine == null) {
        throw DCliException('No file/directory matched ${absolute(path)}');
      }

      final parts = lsLine.split(' ');
      user = parts[2];
      group = parts[3];
    }
  }

  @override
  String toString() {
    return '$user:$group';
  }
}
