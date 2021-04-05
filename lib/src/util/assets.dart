import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import '../../dcli.dart';

///
/// This class provides access to 'assets' packaged in your application.
///
/// TO A POINT!
///
/// Applications deployed using `dart pub global activate` or if you are just
/// running from a local source directory then your app will have
///  access to their
/// assets.
///
/// If you have AOT compiled your application (e.g. dart compile or
/// dcli compile)
/// then you will NOT have access to the assets as they are not deployed.
///
/// To create an asset place it under:
///
/// lib/src/assets
///
/// Unlike flutter you don't need to create any entries in your pubspec.yaml.
///
class Assets {
  ///
  factory Assets() => _self;

  Assets._internal() {
    _packageName = Script.current.pubSpec.name;
  }
  static final _self = Assets._internal();

  String? _packageName;

  /// Loads an asset as a string.
  ///
  /// If you have an asset:
  ///
  /// lib/src/assets/mydir/notes.txt
  ///
  /// ```dart
  /// Assets().loadString('assets/mydir/notes.txt');
  /// ```
  String loadString(String path) =>
      File(_resolveAssetPath(path)).readAsStringSync();

  /// returns a list of assets located under the given [root] directory.
  /// The [root] directory must be relative to the parent of
  /// the 'asset' directory.
  ///
  /// .e.g.
  /// Assets live under
  /// lib/src/assets
  ///
  /// If you have asssets
  /// lib/src/assets/templates/fred.txt
  /// lib/src/assets/templates/tom.txt
  ///
  /// The call
  /// ```dart
  /// var templates = Assets.list(root: 'assets/templates');
  /// ```
  /// Will return a list of fully qualified paths to those assets
  /// on your local file system.
  ///
  /// The [pattern] is a wildcard (glob) that controls what files are returned.
  /// The [root] is the directory to start searching from. It MUST start with assets/.
  /// If it doesn't start with assets/ an ArgumentError will be thrown.
  /// Specify [recursive] = true if you want the list command to
  /// recursively search all
  /// directories under [root].
  ///
  List<String?> list(String pattern,
      {required String root, bool recursive = false}) {
    if (!root.startsWith('assets/')) {
      throw ArgumentError('The root must start with assets/');
    }
    return find(pattern,
            workingDirectory: _resolveAssetPath(root), recursive: recursive)
        .toList();
  }

  /// loads an asset as a byte buffer.
  Uint8List loadBytes(String path) {
    final resolvedUri = waitForEx<Uri?>(
        Isolate.resolvePackageUri(Uri.file('lib/src/assets/templates')))!;

    print('resolved: ${resolvedUri.toFilePath()}');

    return File(_resolveAssetPath(path)).readAsBytesSync();
  }

  /// Converts an asset path of the form assert/somepath/note/txt
  /// to the absolute file system path (usually in .pub-cache)
  String _resolveAssetPath(String path) {
    final resolvedUri = waitForEx<Uri?>(Isolate.resolvePackageUri(
        Uri(scheme: 'package', path: '$_packageName/src/$path')))!;
    return resolvedUri.toFilePath();
  }
}
