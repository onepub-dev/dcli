import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('relativize', () {
    expect(relativize("/dir1/dir2", "/dir1/dir2/dir3/file1"), "dir3/file1");
    expect(relativize("dir1/dir2", "dir1/dir2/dir3/file1"), "dir3/file1");

    // expect(relativize("/lib/app/debug/debug.dart", "/abc/def/three.dart"),
    //     "../../abc/def/three.dart");

    // for an import you have the old path
    // old: lib/util/debug.dart
    // new: /lib/app/debug/debug.dart
    // import which must be updated:
    // import: ../widget/timezone.dart
    // new import path: ../../widget/timezone.dart
    //
    expect(
        calcNewImportPath("/lib/util/debug.dart", "../widget/timezone.dart",
            "/lib/app/debug/debug.dart"),
        "../../widget/timezone.dart");
  });
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
  return p.join(p.normalize(p.absolute(p.dirname(library), p.dirname(import))),
      p.basename(import));
}

/// Calculates the absolute path of [relativePath] when
/// give an [absolutePath] that [relativePath] is relative to.
///
// String calcAbsolutePath(String absolutePath, String relativePath) {
//   String absImportedBy = p.absolute(absolutePath);
//   String dirImportedBy = p.dirname(absImportedBy);

//   p.normalize(p.absolute(absolutePath, relativePath));

//   List<String> importedParts = p.split(p.normalize(relativePath));
//   StackList importedByParts = StackList.fromList(p.split(dirImportedBy));

//   // use the absolute path of [importedBy]
//   // to calculate the absolute path of [relativeImportPath]
//   for (int i; i < importedParts.length; i++) {
//     if (importedParts[i] == "..") {
//       importedByParts.pop();
//     } else {
//       break;
//     }
//   }
// }

// returns the new path to the original import.
String resolve(String newPath, String originalImport) {
  String absoluteImport = p.absolute(originalImport);
  String absoluteNewPath = p.absolute(newPath);
  return relativize(absoluteNewPath, absoluteImport);
}

/// The relativize(Path other) method of java.nio.file.Path used to create a
/// relative path between this path and a given path as a parameter.
/// Relativization is the inverse of resolution.
/// This method creates a relative path that when resolved against
/// this path object, yields a path that helps us to locate the same file as the given path.
///
/// For example, if this [from] path is “/dir1/dir2” and the given
/// [to] path is
///  “/dir1/dir2/dir3/file1”
/// then this method will construct a relative path
/// “dir3/file1”.
/// Where this path and the given path do not have a root component, then a relative path can be constructed.
///
/// If anyone of the paths has a root component then the relative path cannot be constructed.
/// When both paths have a root component then it is implementation-dependent if a relative path
/// can be constructed. If this path and the given path are equal then an empty path is returned.
String relativize(String from, String to) {
  from = p.canonicalize(from);
  to = p.canonicalize(to);
  List<String> fromParts = p.split(from);
  List<String> toParts = p.split(to);
  int fromDepth = fromParts.length;
  int toDepth = toParts.length;

  int commonLength = min(fromDepth, toDepth);

  // determine the common part of the paths
  int commonDepth = 0;
  for (int i = 0; i < commonLength; i++) {
    if (fromParts[i] == toParts[i]) {
      commonDepth++;
    } else {
      break;
    }
  }

  String toUnique = "";
  // get the unique path of to
  for (int i = commonDepth; i < toDepth; i++) {
    toUnique = p.join(toUnique, toParts[i]);
  }

  String climb = "../" * (fromDepth - commonDepth - 2);

  return climb + toUnique;
}
