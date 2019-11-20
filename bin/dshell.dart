import "dart:io";
import 'package:dscript/dscript.dart';
import 'dart:collection';

void main(List<String> arguments) {
  DShell().run(arguments);
}

class DShell {
  String _appName = "dshell";
  String _packageName = "dshell";
  String _version = "1.0.7";

/*
  void loadPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
  */

  void run(List<String> arguments) async {
    // loadPackageInfo();

    if (probeSubCommands(arguments)) {
      exit(-1);
    }

    try {
      Args options = Args.parse(arguments);

      final DetectedDartSdk sdk = DartSdk.detect() as DetectedDartSdk;

      if (options.verbose) {
        stderr.writeln(
            'dshell: Dart SDK found at ${sdk.sdkPath} with version ${await sdk.version}');
      }

      UnmodifiableListView<String> pubspec =
          await extractPubspec(options.script);

      if (pubspec == null || pubspec.isEmpty) {
        if (options.verbose) {
          stderr.writeln(
              'dshell: Embedded pubspec not found in script. Providing defualt pubspec');
        }
        pubspec = UnmodifiableListView<String>(<String>['name: a_dart_script']);
      } else {
        if (options.verbose) {
          stderr.writeln('dshell: Embedded pubspec found in script');
        }
      }

      final ScriptRunner runner =
          await ScriptRunner.make(options, sdk, pubspec);

      if (options.verbose) {
        stderr.writeln(
            'dshell: Temporary project path at ${runner.tempProjectDir}');
      }

      try {
        await runner.createProject();
      } on PubGetException catch (e) {
        stderr.writeln(
            'dshell: Running "pub get" failed with exit code ${e.exitCode}!');
        if (options.verbose) {
          stderr.writeln(e.stderr);
        }
        exit(1);
      }

      final int exitCode = await runner.exec();

      if (options.deleteProject) {
        if (options.verbose) {
          stderr.writeln('dshell: Deleting project');
        }
        try {
          await Directory(runner.tempProjectDir).delete(recursive: true);
        } finally {}
      }

      if (options.verbose) {
        stderr.writeln('dshell: Exiting with code $exitCode');
      }

      await stderr.flush();

      exit(exitCode);
    } catch (e) {
      stderr.writeln((e.toString()));
      exit(-1);
    }
  }

  void printHelp() {
    print(
        'dshell: A bash replacement allowing you to write bash like scripts using dart and run them directly from the cli.');
    print('');
    print('Usage: dshell [-v] [-k] [script-filename] [arguments...]');
    print('Example: calc.dart 20 + 5');
    print('');
    print('Options:');
    print('-v: Verbose');
    print('-k: Keep temporary project files');
    print('');
    print('');
    print('Sub-commands:');
    print('help: Prints help text');
    print('version: Prints version');
  }

  bool probeSubCommands(List<String> args) {
    if (args.isEmpty) {
      print('Version: $_version');
      print('');
      printHelp();
      return true;
    }

    switch (args[0]) {
      case 'version':
        print(_version);
        return true;
      case 'help':
        printHelp();
        return true;
    }

    return false;
  }
}
