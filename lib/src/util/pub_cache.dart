import '../../dshell.dart';

/// Used to locate and manipulate the dart pub cache
///
/// https://dart.dev/tools/pub/environment-variables
///
class PubCache {
  static final PubCache _self = PubCache._internal();

  static const String _pubCacheDir = '.pub-cache';
  static final String _pubCacheBinDir = join(_pubCacheDir, 'bin');
  static const String PUB_CACHE_ENV = 'PUB_CACHE';
  static String _pubCachePath;

  factory PubCache() {
    return _self;
  }

  PubCache._internal();

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
}
