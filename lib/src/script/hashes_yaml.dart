import 'dart:io';
import 'package:path/path.dart' as p;

import 'my_yaml.dart';

class HashesYaml {
  String fileName = 'hashes.yaml';

  MyYaml hashes;

  HashesYaml(String scriptCachePath) {
    var cachePathDirectory = Directory(scriptCachePath);

    if (!cachePathDirectory.existsSync()) {
      cachePathDirectory.createSync();
    }

    hashes = MyYaml.fromFile(p.join(scriptCachePath, fileName));
  }

  static void create(String projectRootPath) {}
}
