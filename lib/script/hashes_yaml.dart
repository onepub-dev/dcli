import 'dart:io';
import 'package:path/path.dart' as p;

import 'yaml.dart';

class HashesYaml {
  String fileName = 'hashes.yaml';

  Yaml hashes;

  HashesYaml(String scriptCachePath) {
    Directory cachePathDirectory = Directory(scriptCachePath);

    if (!cachePathDirectory.existsSync()) {
      cachePathDirectory.createSync();
    }

    hashes = Yaml(p.join(scriptCachePath, fileName));
    hashes.load();
  }

  static void create(String projectRootPath) {}
}
