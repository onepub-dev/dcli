import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'dart_import_app.dart';
import 'line.dart';
import 'move_result.dart';

class Library {
  File sourceFile;
  bool externalLib;
  Directory libRoot;

  Library(this.sourceFile, this.libRoot) {
    externalLib = !_isUnderLibRoot();

    if (this.sourceFile.path.endsWith("office_holidays_dashlet.dart")) {
      DartImportApp().debug("office_holidays_dashlet");
    }

    DartImportApp()
        .debug("Processing: ${sourceFile} externalLib: $externalLib");
  }

  // File get file => sourceFile;

  bool get isExternal => externalLib;

  String get directory => sourceFile.parent.path;

  ///
  /// Returns true if the library is under the lib directory
  bool _isUnderLibRoot() {
    return p.isWithin(libRoot.path, sourceFile.path);
  }

  Future<File> createTmpFile() async {
    Directory systemTempDir = Directory.systemTemp;

    File tmpFile =
        File(p.join(systemTempDir.path, p.relative(sourceFile.path)));

    Directory tmpDir = Directory(tmpFile.parent.path);
    await tmpDir.create(recursive: true);

    return tmpFile;
  }

  void overwrite(File tmpFile) async {
    FileSystemEntity backupFile =
        await sourceFile.rename(sourceFile.path + ".bak");
    await tmpFile.rename(sourceFile.path);
    await backupFile.delete();
  }

  /// Updates any the import statements in the passed
  /// dart [libraryFile] that refer to [fromPath]
  /// so that they now point to 'toPath'.
  /// [fromPath] and [toPath] are [File]s relative to the lib directory.
  ///
  Future<MoveResult> updateImportStatements(File fromPath, File toPath) async {
    // Create temp file to write changes to.
    File tmpFile = await createTmpFile();

    IOSink tmpSink = tmpFile.openWrite();

    MoveResult result = MoveResult(this, tmpFile);

    // print("Scanning: ${file.path}");

    await sourceFile
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) =>
            result.changeCount += replaceLine(line, fromPath, toPath, tmpSink));

    await tmpSink.close();

    return result;
  }

  int replaceLine(String rawLine, File fromPath, File toPath, IOSink tmpSink) {
    String newLine = rawLine;

    int changeCount = 0;

    Line line = Line(this, rawLine);
    newLine = line.update(this, fromPath, toPath);

    if (rawLine != newLine) {
      changeCount++;
    }
    tmpSink.writeln(newLine);

    return changeCount;
  }
}
