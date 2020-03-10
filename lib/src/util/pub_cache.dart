import 'dart:io';

import '../../dshell.dart';

/// Used to locate and manipulate the dart pub cache
///
/// https://dart.dev/tools/pub/environment-variables
///
class PubCache {
  static PubCache _self;

    /// Dart allows the user to modify the location of
    /// the .pub-cache by setting an environment var.
  String _pubCacheDir;
  String _pubCacheBinDir;
  static const String PUB_CACHE_ENV = 'PUB_CACHE';
  String _pubCachePath;

  factory PubCache() {
     _self ??=   PubCache._internal();
     return _self;
  }

  PubCache._internal() {
    _pubCacheDir = '.pub-cache';

    if (Platform.isWindows) {
      _pubCacheDir = join('Pub', 'Cache');
    }
    _pubCacheBinDir = join(HOME, _pubCacheDir, 'bin');
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
  // where executables from installed packages are stored.
  String get binPath => _pubCacheBinDir;

  String get cacheDir => _pubCacheDir;

  /// only to be used for unit tests. 
  /// It resets the paths so that they can pick
  /// up changes to HOME made by the unit tests.
  static void unitTestreset()
  {
    _self = null;
  }
}
