/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:scope/scope.dart';

import '../../dcli.dart';

/// Used to locate and manipulate the dart pub cache
///
/// https://dart.dev/tools/pub/environment-variables
///
class PubCache {
  ///
  factory PubCache() {
    if (Scope.hasScopeKey(scopeKey)) {
      return Scope.use(scopeKey);
    } else {
      return _self ??= PubCache._internal();
    }
  }

  /// Use this ctor to alter the location of .pub-cache
  /// during testing.
  /// ```dart
  ///     withEnvironment(() {
  ///   /// create a pub-cache using the test scope's HOME
  ///   Scope()
  ///     ..value(PubCache.scopeKey, PubCache.forScope())
  ///     ..run(() {
  ///         // do stuff
  ///       });
  ///     });
  /// }, environment: {
  ///   'PUB_CACHE': join(outerTempDir, 'test_cache', '.pub-cache')
  /// });
  ///
  factory PubCache.forScope() => PubCache._internal();

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

  static ScopeKey<PubCache> scopeKey = ScopeKey<PubCache>();

  /// Method taken from the pub_cache package.
  /// We can't use the pub_cache version as it directly
  /// gets Platform.environment so any changes we make
  /// are not visible.
  String _getSystemCacheLocation() {
    if (envs.containsKey('PUB_CACHE')) {
      return envs['PUB_CACHE']!;
    } else if (core.Settings().isWindows) {
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
      return join(envs['HOME']!, '.pub-cache');
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
  /// Prior to Dart 2.19: hosted/pub.dartlang.org
  /// From Dart 2.19: this changed to hosted/pub.dev
  String get pathToHosted => truepath(_pubCachePath, 'hosted', 'pub.dev');

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

  /// Path to the PubCache's hosted/pub.dartlang.org directory
  /// where all of the downloaded packages from pub.dev live.
  String get pathToDartLang => join(_pubCachePath, 'hosted', 'pub.dev');

  /// Returns the path to the package in .pub-cache for the dart
  /// project named [packageName] for the version [version].
  /// e.g.
  /// ~/.pub-cache/hosted/pub.dartlang.org/dswitch-4.0.1
  String pathToPackage(String packageName, String version) =>
      join(pathToDartLang, '$packageName-$version');

  /// Returns true if the package is installed in pub-cache
  bool isInstalled(String packageName) {
    try {
      return findPrimaryVersion(packageName) != null;
    } on core.FindException {
      return false;
    }
  }

  /// Finds and returns the latest (non-pre-release) version installed into pub
  /// cache for the given package.
  ///
  /// If there are no stable versions then a pre-release
  /// version may be returned if one exists.
  ///
  /// If no versions are installed then null is returned.
  Version? findPrimaryVersion(String packageName) {
    if (!exists(pathToDartLang)) {
      return null;
    }
    final packages = find(
      '$packageName-*.*',
      types: [Find.directory],
      workingDirectory: pathToDartLang,
    ).toList();

    if (packages.isEmpty) {
      verbose(() => 'No installed packages for $packageName found');
      return null;
    }

    final primary = Version.primary(
      packages.map((package) {
        final filename = basename(package);
        final firstHyphen = filename.indexOf('-');
        assert(firstHyphen >= 0, 'should always be a hypen after the filename');
        final version = filename.substring(firstHyphen + 1);

        return Version.parse(version);
      }).toList(),
    );
    verbose(() => 'Found primary version $primary for $packageName');
    return primary;
  }

  /// Searches for [requestedVersion] of [packageName] in pub-cache
  /// and returns the fully qualified path to that version.
  /// If the version is not found then null is returned;
  String? findVersion(String packageName, String requestedVersion) {
    if (!exists(pathToDartLang)) {
      return null;
    }
    final packages = find(
      '$packageName-*.*',
      types: [Find.directory],
      workingDirectory: pathToDartLang,
    ).toList();

    if (packages.isEmpty) {
      verbose(() => 'No installed packages for $packageName found');
      return null;
    }

    for (final pathToPackage in packages) {
      final fullPackageName = basename(pathToPackage);
      final firstHyphen = fullPackageName.indexOf('-');
      assert(firstHyphen >= 0, 'should always be a hypen after the filename');

      final packageVersion = fullPackageName.substring(firstHyphen + 1);

      if (packageVersion.compareTo(requestedVersion) == 0) {
        verbose(() => 'Found  version $packageVersion for $packageName '
            'at $pathToPackage');
        return pathToPackage;
      }
    }
    return null;
  }

  /// Run dart pub global activate on the given [packageName].
  /// If [version] is passed then we activate the specific version otherwise
  /// we activate the latest version from  the packages stable channel.
  /// The [verbose] option is for debugging activation problems
  /// and does a full dump to console of the dart pub log.
  void globalActivate(String packageName,
      {String? version, bool verbose = false}) {
    DartSdk().runPub(
      args: [
        'global',
        'activate',
        if (verbose) '--verbose',
        packageName,
        if (version != null) version,
      ],
      progress: Progress.printStdErr(),
    );
  }

  /// Run dart pub global activate for a package located in [path]
  /// relative to the current directory.
  void globalActivateFromSource(String path) {
    DartSdk().runPub(
      args: ['global', 'activate', '--source', 'path', path],
      progress: Progress.printStdErr(),
    );
  }

  /// Run dart pub global deactivate on the given [packageName].
  void globalDeactivate(String packageName) {
    DartSdk().runPub(
      args: ['global', 'deactivate', packageName],
      progress: Progress.printStdErr(),
    );
  }

  /// returns true if the given package has been globally activated
  bool isGloballyActivated(String packageName) {
    const notFound = r'123!!23172@@#$!@!#';

    /// run pub global list to see if dcli is run from a local path.
    final line = DartSdk()
        . runPub(args: ['global', 'list'], progress: Progress.capture())
        .lines
        .firstWhere((line) => line.startsWith(packageName),
            orElse: () => notFound);

    return line.contains(packageName);
  }

  /// Returns true if the the dart project [packageName]
  /// is running from local source.
  /// This means that the package has been activated via
  /// ```bash
  /// dart pub global activate --source path <path to package>
  /// ```
  bool isGloballyActivatedFromSource(String packageName) {
    /// run pub global list to see if dcli is run from a local path.
    final lines = DartSdk()
        .runPub(args: ['global', 'list'], progress: Progress.capture()).lines;

    final line = lines.firstWhere((line) => line.startsWith(packageName),
        orElse: () => packageName);

    return line.contains('at path');
  }
}
