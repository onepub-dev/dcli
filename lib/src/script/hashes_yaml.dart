import 'dart:io';
import 'package:path/path.dart' as p;

import 'my_yaml.dart';

/// not currently used.
/// idea was to keep a hash of files so we can tell if they have changed.
class HashesYaml {
  final String _fileName = 'hashes.yaml';

  /// ignore: unused_field
  MyYaml _hashes;

  ///
  HashesYaml(String scriptCachePath) {
    var cachePathDirectory = Directory(scriptCachePath);

    if (!cachePathDirectory.existsSync()) {
      cachePathDirectory.createSync();
    }

    _hashes = MyYaml.fromFile(p.join(scriptCachePath, _fileName));
  }

  ///
  static void create(String projectRootPath) {}
}
