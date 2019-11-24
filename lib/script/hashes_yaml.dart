import 'dart:io';

import 'yaml.dart';

class HashesYaml {
  String fileName = '.hashes.yaml';

  Yaml hashes;

  HashesYaml(String scriptCachePath) {
    Directory cachePathDirectory = Directory(scriptCachePath);

    if (!cachePathDirectory.existsSync()) {
      cachePathDirectory.createSync();
    }

    hashes = Yaml(scriptCachePath);
    hashes.load();
  }
}
