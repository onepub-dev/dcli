import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import '../util/dcli_exception.dart';
import '../util/logging.dart';
import '../util/truepath.dart';
import 'dcli_function.dart';

/// Provides access to shell environment variables.
Env env = Env();

/// Tests if the given [path] is contained
/// in the OS's PATH environment variable.
/// An canonicalized match of [path] is made against
/// each path on the OS's path.
bool isOnPATH(String path) => Env().isOnPATH(path);

/// Returns the list of directory paths that are contained
/// in the OS's PATH environment variable.
/// They are returned in the same order that they appear within
/// the PATH environment variable (as order is important.)
//ignore: non_constant_identifier_names
List<String> get PATH => Env()._path;

/// returns the path to the OS specific HOME directory
//ignore: non_constant_identifier_names
String get HOME => Env().HOME;

/// Returns a map of all the environment variables
/// inherited from the parent as well as any changes
/// made by calls to [env[]=].
///
/// See [env[]]
///     [env[]=]
Map<String, String> get envs => Env()._envVars;

///
/// Sets gets an environment variable for the current process.
///
/// Passing a null value will remove the key from the
/// set of environment variables.
///
/// Any child process spawned will inherit these changes.
/// e.g.
/// ```
///   /// Set the environment variable 'XXX' to 'A Value'
///   env['XXX'] = 'A Value';
///
///   // the echo command will display the value off XXX.
///   '''echo $XXX'''.run;
///
///   /// Get the current value of an environment variable
///   var xxx = env['XXX'];
///
/// ```
/// NOTE: this does NOT affect the parent
/// processes environment.
///

/// Implementation class for the functions [env[]] and [env[]=].
class Env extends DCliFunction {
  /// Implementation class for the functions [env[]] and [env[]=].
  factory Env() => _self;

  Env._internal() : _caseSensitive = !Platform.isWindows {
    final platformVars = Platform.environment;

    _envVars =
        CanonicalizedMap((key) => _caseSensitive ? key : key.toUpperCase());

    // build a local map with all of the OS environment vars.
    for (final entry in platformVars.entries) {
      _envVars.putIfAbsent(entry.key, () => entry.value);
    }
  }

  static Env _self = Env._internal();

  late Map<String, String> _envVars;

  final bool _caseSensitive;

  /// conveience method for unit tests.
  /// resets all environment variables to the state
  /// we inheritied from the parent process.
  @visibleForTesting
  static void reset() {
    _self = Env._internal();
    env = _self;
  }

  String? _env(String name) {
    verbose(() => 'env:  $name:${_envVars[name]}');

    return _envVars[_caseSensitive ? name : name.toUpperCase()];
  }

  /// Returns the complete set of Environment variable entries.
  Iterable<MapEntry<String, String>> get entries => _envVars.entries;

  /// Adds all of the entries in the [other] map as environment variables.
  /// Case translation will occur if the platform is case sensitive.
  void addAll(Map<String, String> other) {
    for (final entry in other.entries) {
      _setEnv(entry.key, entry.value);
    }
  }

  /// Returns true if an environment variable with the name
  /// [key] exists.
  bool exists(String key) => _envVars.keys.contains(key);

  /// returns the PATH environment var as an ordered
  /// array of the paths contained in the PATH.
  /// The list is ordered Left to right of the paths in
  /// the PATH environment var.
  List<String> get _path {
    final pathEnv = this['PATH'] ?? '';

    return pathEnv
        .split(delimiterForPATH)
        // on linux an empty path equates to the current directory.
        // .where((value) => value.trim().isNotEmpty)
        .toList();
  }

  /// Returns the value of an environment variable.
  ///
  /// name of the environment variable.
  ///
  /// On posix systems name of the environment variable is case sensitive.
  ///
  ///
  ///```dart
  ///String path = env["PATH"];
  ///```
  ///
  String? operator [](String name) => _env(name);

  /// Sets the value of an environment variable
  /// ```dart
  ///   env["PASS"] = 'mypassword';
  /// ```
  ///
  void operator []=(String name, String? value) => _setEnv(name, value);

  /// Appends [newPath] to the list of paths in the
  /// PATH environment variable.
  ///
  /// If [newPath] is already in PATH no action is taken.
  ///
  /// Changing the PATH has no affect on the parent
  /// process (shell) that launched this script.
  ///
  /// Changing the path affects the current script
  /// and any children that it spawns.
  ///
  /// See: [prependToPATH]
  ///   [removeFromPATH]
  void appendToPATH(String newPath) {
    if (!isOnPATH(newPath)) {
      final path = PATH..add(newPath);
      _setEnv('PATH', path.join(delimiterForPATH));
    }
  }

  /// Prepends [newPath] to the list of paths in the
  /// PATH environment variable provided the
  /// path isn't already on the PATH.
  ///
  /// If [newPath] is already in PATH no action is taken.
  ///
  /// Changing the PATH has no affect on the parent
  /// process (shell) that launched this script.
  ///
  /// Changing the path affects the current script
  /// and any children that it spawns.
  ///
  /// See: [appendToPATH]
  ///   [removeFromPATH]
  void prependToPATH(String newPath) {
    if (!isOnPATH(newPath)) {
      final path = PATH..insert(0, newPath);
      _setEnv('PATH', path.join(delimiterForPATH));
    }
  }

  /// Removes the given [oldPath] from the PATH environment variable.
  ///
  /// Changing the PATH has no affect on the parent
  /// process (shell) that launched this script.
  ///
  /// Changing the path affects the current script
  /// and any children that it spawns.
  ///
  /// See: [appendToPATH]
  /// [prependToPATH]
  void removeFromPATH(String oldPath) {
    final path = PATH..remove(oldPath);
    _setEnv('PATH', path.join(delimiterForPATH));
  }

  /// Adds [newPath] to the PATH environment variable
  /// if it is not already present.
  ///
  /// The [newPath] will be added to the end of the PATH list.
  ///
  /// Changing the PATH has no affect on the parent
  /// process (shell) that launched this script.
  ///
  /// Changing the PATH affects the current script
  /// and any children that it spawns.
  @Deprecated('Use appendToPATH')
  void addToPATHIfAbsent(String newPath) => appendToPATH(newPath);

  ///
  /// Gets the path to the user's home directory
  /// using the enviornment var appropriate for the user's OS.
  //ignore: non_constant_identifier_names
  String get HOME {
    String? home;

    if (Platform.isWindows) {
      home = _env('APPDATA');
    } else {
      home = _env('HOME');
    }

    if (home == null) {
      if (Platform.isWindows) {
        throw DCliException(
          "Unable to find the 'APPDATA' enviroment variable. "
          'Please ensure it is set and try again.',
        );
      } else {
        throw DCliException(
          "Unable to find the 'HOME' enviroment variable. "
          'Please ensure it is set and try again.',
        );
      }
    }
    return home;
  }

  /// returns true if the given [checkPath] is in the list
  /// of paths defined in the environment variable [PATH].
  bool isOnPATH(String checkPath) {
    final canon = canonicalize(truepath(checkPath));
    var found = false;
    for (final path in _path) {
      if (canonicalize(truepath(path)) == canon) {
        found = true;
        break;
      }
    }
    return found;
  }

  /// Passing a null [value] will remove the key from the
  /// set of environment variables.
  void _setEnv(String name, String? value) {
    verbose(() => 'env[$name] = $value');
    if (value == null) {
      _envVars.remove(name);
      if (Platform.isWindows) {
        if (name == 'HOME' || name == 'APPDATA') {
          _envVars
            ..remove('HOME')
            ..remove('APPDATA');
        }
      }
    } else {
      _envVars[name] = value;

      if (Platform.isWindows) {
        if (name == 'HOME' || name == 'APPDATA') {
          _envVars['HOME'] = value;
          _envVars['APPDATA'] = value;
        }
      }
    }
  }

  /// returns the delimiter used by the PATH enviorment variable.
  ///
  /// On linix it is ':' ond windows it is ';'
  ///
  /// NOTE do NOT confuses this with the file system path root!!!
  ///
  String get delimiterForPATH {
    var separator = ':';

    if (Platform.isWindows) {
      separator = ';';
    }
    return separator;
  }

  /// Encodes all environment variables to a json string.
  /// This method is intended to be used in conjuction with
  /// [fromJson].
  ///
  /// You will find this method useful when spawning an isolate
  /// that depends on environment variables created by calls
  /// to DCli [env] property.
  ///
  /// When creating an isolate it takes its environment variables
  /// from [Platform.environment]. This means that any environment
  /// variables created via DCli will not be visible to the isolate.
  ///
  /// The way to over come this problem is to call [Env().toJson()]
  /// pass the resulting string to the isolate and then have the
  /// isolate call [Env().fromJson()]  which resets the isolates
  /// environment variables.
  ///
  /// ```dart
  ///void startIsolate() {
  ///   var iso = waitForEx<IsolateRunner>(IsolateRunner.spawn());
  ///
  ///   try {
  ///      iso.run(scheduler, Env().toJson());
  ///   } finally {
  ///     waitForEx(iso.close());
  ///   }
  ///}
  ///
  /// // This method runs in the new isolate.
  /// void scheduler(String jsonEnvironment) {
  ///   Env().fromJson(jsonEnvironment);
  ///   Certbot().scheduleRenews();
  /// }
  /// ```
  String toJson() {
    final envMap = <String, String>{}..addEntries(env.entries.toSet());
    return JsonEncoder(_toEncodable).convert(envMap);
  }

  /// Takes a json string created by [toJson]
  /// clears the current set of environment variables
  /// and replaces them with the environment variables
  /// encoded in the json string.
  ///
  /// If you choose not to use [toJson] to create the json
  /// then [json ] must be in form of an json encoded Map<String,String>.
  void fromJson(String json) {
    _envVars.clear();
    env.addAll(
      Map<String, String>.from(
        const JsonDecoder().convert(json) as Map<dynamic, dynamic>,
      ),
    );
  }

  String _toEncodable(Object? object) => object.toString();

  /// Used in unit tests to mock the Env class.
  // ignore: avoid_setters_without_getters
  static set mock(Env mockEnv) {
    _self = mockEnv;
  }
}

/// Base class for all Environment variable related exceptions.
class EnvironmentException extends DCliException {
  /// Create an environment variable exception.
  EnvironmentException(String message) : super(message);
}
