import 'dart:io';

import '../../dshell.dart';

/// Used to locate and manipulate the dart pub cache
///
/// https://dart.dev/tools/pub/environment-variables
///
class PubCache {
  static final PubCache _self = PubCache._internal();

    String _pubCacheDir ;
    String _pubCacheBinDir;

    /// Dart allows the user to modify the location of
    /// the .pub-cache by setting an environment var.
  static const String PUB_CACHE_ENV = 'PUB_CACHE';
   String _pubCachePath;

  factory PubCache() {
    return _self;
  }

  PubCache._internal()
  {
     _pubCacheDir = '.pub-cache';
   
    if (Platform.isWindows)
    {
      _pubCacheDir = join('Pub', 'Cache');
    }
     _pubCacheBinDir = join(_pubCacheDir, 'bin');
  }

  // Returns the path to the .pub-cache directory
  String get path {
    if (_pubCachePath == null) {
      _pubCachePath = env(PUB_CACHE_ENV);

      _pubCachePath ??= join(HOME, _pubCacheDir);
    }
    return _pubCachePath;
  }

  // Returns the path to the .pub-cache's bin directory
  // were executables from installed packages are stored.
  String get binPath => _pubCacheBinDir;

  String get cacheDir => _pubCacheDir;
}
