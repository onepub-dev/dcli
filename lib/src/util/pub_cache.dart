import 'package:meta/meta.dart';

import '../../dcli.dart';

/// Used to locate and manipulate the dart pub cache
///
/// https://dart.dev/tools/pub/environment-variables
///
class PubCache {
  static PubCache _self;

  /// The name of the pub cache directory (e.g. .pub-cache)
  String _pubCacheDir;

  String _pubCacheBinPath;

  /// The name of the environment variable that can be
  /// set to change the location of the .pub-cache directory.
  /// You should change this path by calling [pathTo].
  static const String envVar = 'PUB_CACHE';
  String _pubCachePath;

  ///
  factory PubCache() => _self ??= PubCache._internal();

  PubCache._internal() {
    // first check if an environment variable exists.
    // The PUB_CACHE env var allows a user to over-ride
    // the standard location of the pub cache.
    final pubCacheEnv = env[envVar];

    /// determine pubCacheDir
    if (pubCacheEnv != null) {
      _pubCacheDir = pubCacheEnv;
    }
    if (Settings().isWindows) {
      _pubCacheDir ??= join('Pub', 'Cache');
      // doco says this is AppData but the dart installer seems to use LocalAppData
      _pubCachePath ??= truepath(join(env['LocalAppData'], _pubCacheDir));
    } else {
      _pubCacheDir ??= '.pub-cache';
      // determine pub-cache path
      _pubCachePath ??= truepath(join(env['HOME'], _pubCacheDir));
    }

    // determine pub-cache/bin
    _pubCacheBinPath = truepath(join(_pubCachePath, 'bin'));
  }

  /// The fully qualified path to the pub cache.
  ///
  /// Dart allows the user to modify the location of
  /// the .pub-cache by setting the environment var
  /// PUB_CACHE.
  ///
  /// This method processes PUB_CACHE if it exists.
  String get pathTo => _pubCachePath;

  /// Updates the PUB_CACHE environment variable
  /// which will cause pub get (and friends) to look to this
  /// alternate path.
  ///
  /// This will only affect any child processes spawned from
  /// this script.
  set pathTo(String pathToPubCache) {
    env[envVar] = pathToPubCache;
    _pubCachePath = pathToPubCache;
  }

  /// The fully qualified path to the pub cache's bin directory
  /// where executables from installed packages are stored.
  String get pathToBin => _pubCacheBinPath;

  /// Returns the directory name of the pub cache.
  ///
  /// e.g.
  /// .pub-cache
  ///
  /// Dart allows the user to modify the location of
  /// the .pub-cache by setting the environment var
  /// PUB_CACHE.
  ///
  /// This method processes PUB_CACHE if it exists.
  String get cacheDir => _pubCacheDir;

  /// only to be used for unit tests.
  /// It resets the paths so that they can pick
  /// up changes to HOME made by the unit tests.
  @visibleForTesting
  static void reset() {
    _self = null;
  }
}
