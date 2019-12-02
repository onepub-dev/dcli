import 'dart:io';
import 'package:path/path.dart' as p;

import 'my_yaml.dart';

class HashesYaml {
  String fileName = 'hashes.yaml';

  MyYaml hashes;

  HashesYaml(String scriptCachePath) {
    Directory cachePathDirectory = Directory(scriptCachePath);

    if (!cachePathDirectory.existsSync()) {
      cachePathDirectory.createSync();
    }

    hashes = MyYaml.loadFromFile(p.join(scriptCachePath, fileName));
  }

  static void create(String projectRootPath) {}
}
