import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:args/command_runner.dart';

import 'dart_import_app.dart';
import 'library.dart';
import 'line.dart';
import 'move_result.dart';
import 'pubspec.dart';

class MoveCommand extends Command<void> {
  // This is the lib directory
  Directory libRoot;
  @override
  String get description =>
      "Moves a dart library and updates all import statements to reflect its now location.";

  @override
  String get name => "move";

  MoveCommand() {
    argParser.addOption("root",
        defaultsTo: ".",
        help: "The path to the root of your project.",
        valueHelp: "path");
    argParser.addFlag("debug",
        defaultsTo: false, negatable: false, help: "Turns on debug ouput");
    argParser.addFlag("version",
        abbr: "v",
        defaultsTo: false,
        negatable: false,
        help: "Outputs the version of drtimport and exits.");
  }

  void run() async {
    Directory.current = argResults["root"];
    libRoot = Directory(p.join(Directory.current.path, 'lib'));

    if (argResults["version"] == true) {
      fullusage();
    }

    if (argResults["debug"] == true) DartImportApp().enableDebug();

    if (argResults.rest.length != 2) {
      fullusage();
    }
    if (!await File("pubspec.yaml").exists()) {
      fullusage(
          error: "The pubspec.yaml is missing from: ${Directory.current}");
    }

    // check we are in the root.
    if (!await libRoot.exists()) {
      fullusage(error: "You must run a move from the root of the package.");
    }

    Line.init();

    String from = argResults.rest[0];
    String to = argResults.rest[1];

    if (isDirectory(from)) {
      await processDirectory(from, to);
    } else {
      File fromPath = await validFrom(from);

      await process(fromPath, to, false);
    }
  }

  void processDirectory(String from, String to) async {
    Directory fromPath = await validFromDirectory(from);

    for (var entry in fromPath.listSync()) {
      if (entry is File) {
        await process(entry, to, true);
      }
    }
  }

  void process(File fromPath, String to, bool fromDirectory) async {
    if (isDirectory(to)) {
      // The [to] path is a directory so use the
      // fromPaths filename to complete the target pathname.
      to = p.join(to, p.basename(fromPath.path));
    } else {
      if (fromDirectory) {
        // The target must also be a directory and it must exist
        fullusage(
            error:
                "The <to> path ${expandPath(to)} MUST be a directory and it must exist");
      }
    }

    File toPath = await validTo(to);

    print("Renaming: ${fromPath} to ${toPath}");

    Stream<FileSystemEntity> files = Directory.current.list(recursive: true);

    List<FileSystemEntity> dartFiles =
        await files.where((file) => file.path.endsWith(".dart")).toList();

    List<MoveResult> updatedFiles = List();
    int scanned = 0;
    int updated = 0;
    for (var library in dartFiles) {
      scanned++;

      Library processing = Library(File(library.path), libRoot);
      MoveResult result =
          await processing.updateImportStatements(fromPath, toPath);

      if (result.changeCount != 0) {
        updated++;
        updatedFiles.add(result);

        print("Updated : ${library.path} changed ${result.changeCount} lines");
      }
    }

    await overwrite(updatedFiles);

    await fromPath.exists();

    await fromPath.rename(toPath.path);
    print("Finished: scanned $scanned updated $updated");
  }

  ///
  /// [from] can be a file or a path.
  ///
  Future<File> validFrom(String from) async {
    // all file paths are relative to lib/ but
    // the imports don't include lib so devs
    // will just pass in the name as the see it in the import statement (e.g. no lib)
    // but when we are validating the actual path we need the lib.

    File actualPath = File(p.canonicalize(p.join("lib", from)));

    if (!await actualPath.exists()) {
      fullusage(
          error:
              "The <fromPath> is not a valid filepath: '${actualPath.path}'");
    }
    return actualPath;
  }

  ///
  /// [from] can be a file or a path.
  ///
  Future<Directory> validFromDirectory(String from) async {
    // all file paths are relative to lib/ but
    // the imports don't include lib so devs
    // will just pass in the name as the see it in the import statement (e.g. no lib)
    // but when we are validating the actual path we need the lib.

    Directory actualPath = Directory(p.canonicalize(p.join("lib", from)));

    if (!await actualPath.exists()) {
      fullusage(
          error:
              "The <fromPath> is not a valid filepath: '${actualPath.path}'");
    }
    return actualPath;
  }

  ///
  /// [to] can be a file or a path.
  ///
  Future<File> validTo(String to) async {
    // all file paths are relative to lib/ but
    // the imports don't include lib so devs
    // will just pass in the name as the see it in the import statement (e.g. no lib)
    // but when we are validating the actual path we need the lib.
    File actualPath = File(p.canonicalize(p.join("lib", to)));
    if (!await actualPath.parent.exists()) {
      fullusage(
          error: "The <toPath> directory does not exist: ${actualPath.parent}");
    }
    return actualPath;
  }

  void overwrite(List<MoveResult> updatedFiles) async {
    for (MoveResult result in updatedFiles) {
      await result.library.overwrite(result.tmpFile);
    }
  }

  String expandPath(String path) {
    return p.join("lib", path);
  }

  bool isDirectory(String path) {
    FileSystemEntityType fromType = FileSystemEntity.typeSync(expandPath(path));
    return (fromType == FileSystemEntityType.directory);
  }

  void fullusage({String error}) async {
    if (error != null) {
      print("Error: $error");
      print("");
    }

    PubSpec pubSpec = PubSpec();
    await pubSpec.load();
    String version = pubSpec.version;
    print("drtimport version: ${version}");
    print("Usage: ");
    print("Run the move from the root of the package");
    print("move <from path> <to path>");
    print("e.g. move apps/string.dart  util/string.dart");
    print(argParser.usage);

    exit(-1);
  }
}
