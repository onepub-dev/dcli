import 'dart:io';

import 'package:path/path.dart' as p;

import 'dart_import_app.dart';
import 'library.dart';
import 'pubspec.dart';

enum ImportType {
  NOT // not an import line
  ,
  RELATIVE // a relative path to a library
  ,
  LOCAL_PACKAGE // a package path to an internal libary
  ,
  BUILT_IN // a dart package
  ,
  EXTERNAL_PACKAGE // a package path to an external library
}

class Line {
  static String _projectName;
  static Directory libRoot;
  static String projectPrefix;
  static String dartPrefix = "dart:";
  static String packagePrefix = "package:";

  // The library source file that this line comes from.
  Library sourceLibrary;
  ImportType _importType;
  // absolute path to the imported library.
  String _importedPath;
  String originalLine;
  String normalised;

  String get importedPath => _importedPath;

  static void init() async {
    _projectName = await getProjectName();
    projectPrefix = "package:${_projectName}";
    libRoot = Directory(p.join(Directory.current.path, 'lib'));
  }

  Line(this.sourceLibrary, String line) {
    originalLine = line;
    normalised = normalise(line);
    if (!__isImportLine(line)) {
      _importType = ImportType.NOT;
    } else if (__builtInLibrary(line)) {
      _importType = ImportType.BUILT_IN;
    } else if (__isExternalPackage(line)) {
      _importType = ImportType.EXTERNAL_PACKAGE;
    } else if (__isLocalPackage(line)) {
      _importType = ImportType.LOCAL_PACKAGE;
      _importedPath = _extractImportedPath();
    } else {
      _importType = ImportType.RELATIVE;
      _importedPath = _extractImportedPath();
    }
  }

  bool get isImportLine => _importType != ImportType.NOT;
  bool get isBuiltInLibrary => _importType == ImportType.BUILT_IN;

  bool __isImportLine(String normalised) {
    return normalised.startsWith("import") || normalised.startsWith("export");
  }

  bool __builtInLibrary(String normalised) {
    return normalised.startsWith("import 'dart:");
  }

  bool __isExternalPackage(String normalised) {
    return normalised.startsWith("import 'package:");
  }

  bool __isLocalPackage(String normalised) {
    return normalised.startsWith("import '${projectPrefix}") ||
        normalised.startsWith("export '${projectPrefix}");
  }

  // import 'package:square_phone/yaml.dart';  - consider
  // import 'package:yaml/yaml.dart'; - ignore
  // import 'dart:io'; - ignore
  // import 'yaml.dart'; - consider.

  /// Extracts the import path and returns
  /// an absolute path,
  /// unless the path is to an external package
  /// in which case we simply return the original path.
  String _extractImportedPath() {
    String quoted = _extractQuoted();
    String importedPath;

    bool relativeToSource = false;
    bool isInternal = false;
    ;

    // extract the quoted path sans any package/dart prefix.
    if (quoted.startsWith(projectPrefix)) {
      isInternal = true;
      importedPath = quoted.substring(projectPrefix.length);
    } else if (quoted.startsWith(dartPrefix)) {
      importedPath = quoted.substring(dartPrefix.length);
    } else if (quoted.startsWith(packagePrefix)) {
      importedPath = quoted.substring(packagePrefix.length);
    } else {
      isInternal = true;
      relativeToSource = true;
      importedPath = quoted;
    }
    // strip leading slash as a paths must be relative.
    if (importedPath.startsWith(p.separator)) {
      importedPath = importedPath.replaceFirst(p.separator, "");
    }

    String finalPath;
    if (isInternal) {
      if (relativeToSource) {
        finalPath =
            p.canonicalize(p.join(sourceLibrary.directory, importedPath));
      } else {
        finalPath = p.canonicalize(p.join(libRoot.path, importedPath));
      }
    } else {
      // the import is to an external library so we don't modify it.
      finalPath = importedPath;
    }

    return finalPath;
  }

  /// Extract the components between the quotes in the import statement.
  String _extractQuoted() {
    String regexString = r"'.*'";
    RegExp regExp = RegExp(regexString);
    String matches = regExp.stringMatch(normalised);
    if (matches.isEmpty) {
      throw Exception(
          "import line did not contain a valid path: ${normalised}");
    }
    return matches.substring(1, matches.length - 1);
  }

  ///
  /// Remove the package declaration from local files.
  String normalise(String line) {
    String normalised = line.trim();
    // make certain we only have single spaces
    normalised = normalised.replaceAll("  ", " ");
    // ensure we are using single quotes.
    normalised = normalised.replaceAll("\"", "'");
    return normalised;
  }

  /// reads the project name from the yaml file
  ///
  static Future<String> getProjectName() async {
    PubSpec pubSpec = PubSpec();
    await pubSpec.load();
    return pubSpec.name;
  }

  String update(Library currentLibrary, File fromFile, File toFile) {
    ///NOTE: all imports are relative to the 'lib' directory.
    ///

    String line = originalLine;
    bool replaced = false;

    if (_importType == ImportType.RELATIVE ||
        _importType == ImportType.LOCAL_PACKAGE) {
      DartImportApp().debug("Processing line: ${originalLine}");
      String relativeFromPath = p.relative(fromFile.path, from: libRoot.path);

      String importsRelativePath = p.relative(importedPath, from: libRoot.path);

      if (currentLibrary.sourceFile.path == fromFile.path) {
        // We are processing the file we are moving.
        String relativeImportPath = p.relative(importedPath,
            from: currentLibrary.sourceFile.parent.path);
        String newImportPath =
            calcNewImportPath(fromFile.path, relativeImportPath, toFile.path);

        line = replaceImportPath('${newImportPath}');
        replaced = true;
        DartImportApp().debug("Line is from moved library");
      } else {
        // processing any library but the one we are moving.
        String relativeToLibrary = p.relative(toFile.path,
            from: currentLibrary.sourceFile.parent.path);
        String relativeToLibRoot = p.relative(toFile.path, from: libRoot.path);

        // does the import path match the file we are looking to change.
        DartImportApp().debug(
            "importsRelativePath: $importsRelativePath relativeFromPath: $relativeFromPath");
        if (importsRelativePath == relativeFromPath) {
          /// [externalLib] The library we are parsing is outside the lib dir (e.g. bin/main.dart)
          if (currentLibrary.isExternal) {
            DartImportApp().debug("Library is external, package is local");
            // relative to the 'lib' directory.
            line = replaceImportPath(
                'package:${_projectName}/${relativeToLibRoot}');
            replaced = true;
          } else if (_importType == ImportType.LOCAL_PACKAGE) {
            DartImportApp().debug("Library is internal, package is local");
            // relative to the 'lib' directory.
            line = replaceImportPath(
                'package:${_projectName}/${relativeToLibRoot}');
            replaced = true;
          } else {
            // must be a [ImportType.RELATIVE]
            DartImportApp().debug("Library is internal, path is relative");
            line = replaceImportPath('${relativeToLibrary}');
            replaced = true;
          }
        }
      }
    }

    if (replaced) {
      DartImportApp().debug("New line: ${line}");
    }
    return line;
  }

  ///
  /// Takes an relative [import] path contained within [originalLibrary]
  /// and determines the new import path required to place the same [import]
  /// in the new library.
  /// e.g.
  /// [originalLibrary]: /lib/util/debug.dart
  /// [import] ../widget/timezone.dart
  /// [newLibrary]: /lib/app/debug/debug.dart
  /// Result: ../../widget/timezone.dart
  String calcNewImportPath(
      String originalLibrary, String import, String newLibrary) {
    String absImport = resolveImport(originalLibrary, import);
    return p.relative(absImport, from: p.dirname(newLibrary));
  }

  ///
  /// Returns the absolute path of an imported file.
  /// Uses the absolute path of the [library] that
  /// the imported file is imported from
  /// to calculate the imported files location.
  ///
  String resolveImport(String library, String import) {
    return p.join(
        p.normalize(p.absolute(p.dirname(library), p.dirname(import))),
        p.basename(import));
  }

  ///
  /// replaces the path component of the original import statement with
  /// a new path.
  /// This is important as an import can have an 'as' or 'show' statement
  /// after the path and we don't want to interfere with it.
  String replaceImportPath(String newPath) {
    return this.originalLine.replaceFirst(_extractQuoted(), newPath);
  }
}
