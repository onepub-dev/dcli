import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

class PatchCommand extends Command<void> {
  @override
  String get description =>
      "Patches import statements by doing a string replace.";

  @override
  String get name => "patch";

  void run() {
    if (argResults.rest.length != 2) {
      fullusage(argParser);
      exit(-1);
    }
    String fromPattern = argResults.rest[0];
    String toPattern = argResults.rest[1];

    process(fromPattern, toPattern);
  }

  void process(String fromPattern, String toPattern) async {
    Directory cwd = Directory(".");

    Stream<FileSystemEntity> files = cwd.list(recursive: true);

    List<FileSystemEntity> dartFiles =
        await files.where((file) => file.path.endsWith(".dart")).toList();

    int scanned = 0;
    int updated = 0;
    for (var file in dartFiles) {
      scanned++;
      Result result = await replaceString(file, fromPattern, toPattern);
      File tmpFile = result.tmpFile;

      if (result.changeCount != 0) {
        updated++;
        FileSystemEntity backupFile = await file.rename(file.path + ".bak");
        await tmpFile.rename(file.path);
        await backupFile.delete();

        print("Updated : ${file.path} changed ${result.changeCount} lines");
      }
    }
    print("Finished: scanned $scanned updated $updated");
  }

  Future<Result> replaceString(
      FileSystemEntity file, String fromPattern, String toPattern) async {
    Directory systemTempDir = Directory.systemTemp;

    String tmpPath = p.join(systemTempDir.path, file.path);
    File tmpFile = File(tmpPath);

    Directory tmpDir = Directory(tmpFile.parent.path);
    await tmpDir.create(recursive: true);

    IOSink tmpSink = tmpFile.openWrite();

    Result result = Result(tmpFile);

    await File(file.path)
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) => result.changeCount +=
            replaceLine(line, fromPattern, toPattern, tmpSink));

    return result;
  }

  int replaceLine(
      String line, String fromPattern, String toPattern, IOSink tmpSink) {
    String newLine = line;

    int changeCount = 0;

    if (line.startsWith("import")) {
      newLine = line.replaceAll(fromPattern, toPattern);
    }
    if (line != newLine) {
      changeCount++;
    }
    tmpSink.writeln(newLine);

    return changeCount;
  }

  void fullusage(ArgParser parser) {
    print("Usage: ");
    print("<from string> <to string>");
    print("e.g. AppClass app_class");
    print(parser.usage);
  }
}

class Result {
  File tmpFile;
  int changeCount = 0;

  Result(this.tmpFile);
}
