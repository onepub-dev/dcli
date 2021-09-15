import 'dart:io';

import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../dcli.dart';
import '../settings.dart';

/// Used to locate and manipulate the dart pub cache
///
/// https://dart.dev/tools/pub/environment-variables
///
class PubCache {
  ///
  factory PubCache() => _self ??= PubCache._internal();

  PubCache._internal() {
    _pubCachePath = _getSystemCacheLocation();
    _pubCacheDir = basename(_pubCachePath);

    // // determine pub-cache path
    // if (Shell.current.isSudo) {
    //   /// I'm really not certain about this.
    //   /// The logic is that if we are running under sudo then the pub-cache
    //   /// we are using actually belongs to the original user so
    //   /// we get that user's home directory and pub cache.
    //   final home = (Shell.current as PosixShell).loggedInUsersHome;
    //   _pubCachePath = truepath(join(home, dir));
    // } else {
    //   _pubCachePath = truepath(join(env['HOME']!, dir));
    // }

    verbose(() => 'pub-cache found in=$_pubCachePath');

    // determine pub-cache/bin
    _pubCacheBinPath = truepath(join(_pubCachePath, 'bin'));
  }

  /// Method taken from the pub_cache package.
  /// We can't use the pub_cache version as it directly
  /// gets Platform.environment so any changes we make
  /// are not visible.
  String _getSystemCacheLocation() {
    if (envs.containsKey('PUB_CACHE')) {
      return envs['PUB_CACHE']!;
    } else if (Platform.isWindows) {
      // See https://github.com/dart-lang/pub/blob/master/lib/src/system_cache.dart.

      // %LOCALAPPDATA% is preferred as the cache location over %APPDATA%,
      // because the latter is synchronised between
      // devices when the user roams between them, whereas the former is not.
      // The default cache dir used to be in %APPDATA%, so to avoid breaking
      //old installs,
      // we use the old dir in %APPDATA% if it exists.
      //   else, we use the new default location
      // in %LOCALAPPDATA%.
      if (envs.containsKey('APPDATA')) {
        final appDataCacheDir = join(envs['APPDATA']!, 'Pub', 'Cache');
        if (exists(appDataCacheDir)) {
          return appDataCacheDir;
        }
      }
      if (envs.containsKey('LOCALAPPDATA')) {
        return join(envs['LOCALAPPDATA']!, 'Pub', 'Cache');
      } else {
        /// what else can we do.
        return join(
          envs['HOME'] ?? join(r'C:\Users', envs['USERNAME']),
          '.pub-cache',
        );
      }
    } else {
      return '${envs['HOME']}/.pub-cache';
    }
  }

  /// The name of the environment variable that can be
  /// set to change the location of the .pub-cache directory.
  /// You should change this path by calling [pathTo].
  static const String envVarPubCache = 'PUB_CACHE';
  late String _pubCachePath;

  static PubCache? _self;

  /// The name of the pub cache directory (e.g. .pub-cache)
  late String _pubCacheDir;

  late String _pubCacheBinPath;

  /// The fully qualified path to the pub cache.
  ///
  /// Dart allows the user to modify the location of
  /// the .pub-cache by setting the environment var
  /// PUB_CACHE.
  ///
  /// This method processes PUB_CACHE if it exists.
  String get pathTo => _pubCachePath;

  /// Updates pathTo, pathToBin and the PUB_CACHE environment variable
  /// which will cause pub get (and friends) to look to this
  /// alternate path.
  ///
  /// This will only affect this script and any child processes spawned from
  /// this script.
  set pathTo(String pathToPubCache) {
    env[envVarPubCache] = pathToPubCache;
    _pubCachePath = pathToPubCache;
    _pubCacheBinPath = truepath(join(_pubCachePath, 'bin'));
  }

  /// The fully qualified path to the pub cache's bin directory
  /// where executables from installed packages are stored.
  String get pathToBin => _pubCacheBinPath;

  /// Path to the pub cache hosted directory
  /// hosted/pub.dartlang.org
  String get pathToHosted =>
      truepath(_pubCachePath, 'hosted', 'pub.dartlang.org');

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

  /// Path to the PubCache's hosted/pub.dartlang.org directory
  /// where all of the downloaded packages from pub.dev live.
  String get pathToDartLang =>
      join(_pubCachePath, 'hosted', 'pub.dartlang.org');

  /// Returns the path to the package in .pub-cache for the dart
  /// project named [name] for the version [version].
  /// e.g.
  /// ~/.pub-cache/hosted/pub.dartlang.org/dswitch-4.0.1
  String pathToPackage(String name, String version) =>
      join(pathToDartLang, '$name-$version');

  /// Finds and returns the latest (non-pre-release) version installed into pub
  /// cache for the given package.
  ///
  /// If there are no stable versions then a pre-release
  /// version may be returned if one exists.
  ///
  /// If no versions are installed then null is returned.
  Version? findPrimaryVersion(String packageName) {
    final versions = find(
      '$packageName-*.*',
      types: [Find.directory],
      workingDirectory: pathToDartLang,
    ).toList();

    if (versions.isEmpty) {
      return null;
    }

    return Version.primary(
      versions
          .map((version) => Version.parse(basename(version).split('-')[1]))
          .toList(),
    );
  }
}
