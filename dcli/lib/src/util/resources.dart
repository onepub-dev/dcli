/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:crypto/crypto.dart';
import 'package:settings_yaml/settings_yaml.dart';

import '../../dcli.dart';
import '../script/commands/pack.dart';

/// Packages a file as a dart library so it can be expanded
/// during the install process.
/// This provide a way of shipping small resources in a dart application
/// even if the app is compiled.
/// NOTE: if you are publishing your dart app to pub.dev then
/// there is a 10MB limit imposed by pub.dev.
///
/// If a resource path ends with the extension '.dcl_template'
/// then the '.dcli_template' extension will be stripped from the
/// filename when it is unpacked.
/// e.g.
/// my_class.dart.dcli_template  -> my_class.dart
///
///
class Resources {
  /// the directory where we expect to find the resources
  /// we are going to pack.
  static final String _resourceRoot = join('resource');

  /// relative path to generated root.
  static final String _generatedRoot =
      join('lib', 'src', 'dcli', 'resource', 'generated');

  /// relative path to registry
  static final String _pathToRegistry =
      join(_generatedRoot, 'resource_registry.g.dart');

  /// Path to the registry library
  late final String pathToRegistry =
      join(DartProject.self.pathToProjectRoot, _pathToRegistry);

  /// Directory where will look for resources to pack
  late final String resourceRoot =
      join(DartProject.self.pathToProjectRoot, _resourceRoot);

  /// directory where we save the packed resources.
  late final String generatedRoot =
      join(DartProject.self.pathToProjectRoot, _generatedRoot);

  /// Packs the set of files located under [resourceRoot]
  /// Each resources is packed into a separate dart library
  /// and placed in the [generatedRoot] directory.
  ///
  /// A registry file will be generated in generated/resource_registry.g.dart
  /// which you can include to unpack the files onto the
  /// production system.
  ///
  void pack() {
    /// clear out an old generated files
    /// as we use UUIDs if we didn't do this the
    /// directory would keep growing.
    if (exists(generatedRoot)) {
      deleteDir(generatedRoot);
    }
    createDir(generatedRoot, recursive: true);
    var resources = <String>[];

    if (exists(resourceRoot)) {
      resources = find('*', workingDirectory: resourceRoot).toList();
    }

    final packedResources = _packResources(resources);
    _checkForDuplicates(packedResources);
    print(' - generating registry');
    _writeRegistry(packedResources);
    print(green('Pack complete'));
  }

  List<_Resource> _packResources(List<String> pathToResources) {
    final resources = <_Resource>[];

    for (final pathToResouce in pathToResources) {
      if (isDirectory(pathToResouce)) {
        continue;
      }
      final className = _generateClassName(pathToResouce);

      final pathToGeneratedLibrary = join(generatedRoot, '$className.g.dart');
      print(' - packing: $pathToResouce into $pathToGeneratedLibrary');

      final resource =
          _packResource(pathToResouce, pathToGeneratedLibrary, className);
      resources.add(resource);
    }

    resources.addAll(_packExternalResources());
    return resources;
  }

  /// Encode and write the resource into a dart library.
  _Resource _packResource(
      String pathToResource, String pathToGeneratedLibrary, String className,
      {String? mount}) {
    mount ??= relative(pathToResource, from: resourceRoot);
    final resource = _Resource(
        pathToResource, pathToGeneratedLibrary, className,
        pathToMount: mount);
    final to = File(pathToGeneratedLibrary).openWrite();
    try {
      /// write the header
      to.write('''
// ignore: prefer_relative_imports
import 'package:dcli/dcli.dart';

/// GENERATED -- GENERATED
///
/// DO NOT MODIFIY
///
/// This script is generated via [Resource.pack()].
///
/// GENERATED - GENERATED

class $className extends PackedResource {
  /// PackedResource - ${relative(pathToResource, from: 'resource')}
  const $className();
''');

      _writeChecksum(to, resource.checksum);
      _writePath(to, resource.pathToMount);
      _writeContent(to, pathToResource);

      /// close the class
      to.write('''

}
''');

      waitForEx<dynamic>(to.flush());
    } finally {
      to.close();
    }

    return resource;
  }

  // bool _isAlpha(int char) =>
  //     (char >= 'a'.codeUnits[0] && char <= 'z'.codeUnits[0]) ||
  //     (char >= 'A'.codeUnits[0] && char <= 'Z'.codeUnits[0]);

  /// generates an md5 hash of the file path so we have a unique
  /// name for each resource that is consistent each time we generated it
  /// This helps us manage the resources in git as their name
  /// doesn't change each time we generate them.
  /// For must projects the generated files shouldn't be in git
  /// but for dcli that is impractical as dcli won't run without
  /// them so we have a bootstrapping problem.
  /// We prefix the md5 hash with the letter 'A' so that it can
  /// be used as a valid class name.
  String _generateClassName(String pathToResource) =>
      'A${md5.convert(utf8.encode(pathToResource)).toString()}';

  void _writeRegistry(List<_Resource> resources) {
    final registryFile = File(pathToRegistry).openWrite();
    try {
      // import 'package:dcli/src/dcli/resources/generated/Bbcded.g.dart';
      /// Write the imports
      ///
      registryFile.write('''
// ignore: prefer_relative_imports
import 'package:dcli/dcli.dart';
''');

      /// sort the resources so the imports are sorted.
      for (final resource in resources
        ..sort((a, b) => a.className.compareTo(b.className))) {
        registryFile
            .writeln("import '${basename(resource.pathToGeneratedLibrary)}';");
      }

      {
        registryFile.write(
          '''

/// GENERATED -- GENERATED
///
/// DO NOT MODIFIY
///
/// This script is generated via [Resource.pack()].
///
/// GENERATED - GENERATED

class ResourceRegistry {
  /// Map of the packed files.
  /// Use the path of a packed file (relative to the resource directory)
  /// to access the packed resource and then call [PackedResource].unpack()
  /// to unpack the file.
  /// ```dart
  /// ResourceRegistry.resources['rules.yaml']
  ///     .unpack(join(HOME, '.mysettings', 'rules.yaml'));
  /// ```
  static const resources = <String, PackedResource>{
''',
        );
      }

      /// Write each resource into the map
      for (final resource in resources) {
        final line = _buildMapping(resource);
        registryFile.write('''
$line
''');
      }

      /// Write tail
      registryFile.write('''
  };
}
''');
    } finally {
      waitForEx<dynamic>(registryFile.flush());
      registryFile.close();
    }
  }

  String _buildMapping(_Resource resource) {
    final oneline = "    '${resource.pathToMount.replaceAll(r'\', '/')}':"
        ' ${resource.className}(),';

    String line;
    if (oneline.length <= 80) {
      line = oneline;
    } else {
      line = '''
    '${resource.pathToMount.replaceAll(r'\', '/')}':
        ${resource.className}(),''';
    }
    return line;
  }

  void _writeContent(IOSink to, String pathToResource) {
    to.write(
      '''

  @override
  String get content => \'''
''',
    );

    /// Write the content
    final reader = ChunkedStreamReader(File(pathToResource).openRead());

    /// ignore: literal_only_boolean_expressions
    while (true) {
      final data = waitForEx(reader.readChunk(60));
      to
        ..write(base64.encode(data))
        ..writeln();
      if (data.length < 60) {
        break;
      }
    }

    /// Close the base64 encoded content string
    to.write('''
  \'\'\';''');
  }

  void _writeChecksum(IOSink to, String checksum) {
    // write the checksum
    to.write('''

  /// A hash of the resource (pre packed) calculated by
  /// [calculateHash].
  /// This hash can be used to check if the resource needs to
  /// be updated on the target system.
  /// Use :
  /// ```dart
  ///   calculateHash(pathToResource).hexEncode() == packResource.checksum
  /// ```
  /// to compare the checksum of the local file with
  /// this checksum
  @override
  String get checksum =>
      '$checksum';
''');
  }

  void _writePath(IOSink to, String pathToMount) {
    to.write('''

  /// <package>/resources relative path to the original resource.
  @override
  String get originalPath => '${pathToMount.replaceAll(r'\', '/')}';
''');
  }

  List<_Resource> _packExternalResources() {
    final resources = <_Resource>[];

    final pathToPackYaml = PackCommand.pathToPackYaml;
    if (!exists(pathToPackYaml)) {
      print(orange('No $pathToPackYaml found'));
      return resources;
    }
    final yaml = SettingsYaml.load(pathToSettings: pathToPackYaml);
    final externals = yaml.selectAsList('externals');
    if (externals == null) {
      print(orange('No externals key found in pack.yaml'));
      return resources;
    }

    var index = 0;
    for (final external in externals) {
      // ignore: avoid_dynamic_calls
      var path = external['path'] as String? ?? '';

      if (path.isEmpty) {
        throw ResourceException('external entry in $pathToPackYaml '
            'is missing a "path" key.');
      }
      // convert to absolute path.
      path = truepath(path);

      // ignore: avoid_dynamic_calls
      final mount = external['mount'] as String? ?? '';

      if (mount.isEmpty) {
        throw ResourceException('external entry in $pathToPackYaml '
            'is missing a "mount" key.');
      }

      // list of files/directories to exclude
      // relative to [path]
      final excludes = getExcludedPaths(yaml, path, index);

      if (!exists(path)) {
        throw ResourceException('The path ${truepath(path)} in '
            '$pathToPackYaml does not exist.');
      }
      resources.addAll(_packExternalResource(path, mount, excludes));
      index++;
    }
    return resources;
  }

  List<_Resource> _packExternalResource(
      String path, String mount, List<String> excludes) {
    final resources = <_Resource>[];

    if (isExcluded(path, excludes)) {
      return [];
    }

    if (isDirectory(path)) {
      resources.addAll(_packExternalDirectory(path, mount, excludes));
    } else {
      resources.add(_packExternalFile(path, mount));
    }
    return resources;
  }

  bool isExcluded(String path, List<String> excludes) {
    final exclude = excludes.contains(path);
    Settings().verbose('checking esclusion $path $excludes');
    if (exclude) {
      print(orange(' - excluded: $path'));
    }
    return exclude;
  }

  _Resource _packExternalFile(String path, String mount) {
    final className = _generateClassName(path);

    final pathToGeneratedLibrary = join(generatedRoot, '$className.g.dart');
    print(' - packing: $path into $pathToGeneratedLibrary');

    final resource =
        _packResource(path, pathToGeneratedLibrary, className, mount: mount);
    return resource;
  }

  Iterable<_Resource> _packExternalDirectory(
      String path, String mount, List<String> excludes) {
    final resources = <_Resource>[];

    find('*', workingDirectory: path).forEach((entity) {
      if (!isExcluded(entity, excludes)) {
        if (isFile(entity)) {
          final fileMount = join(mount, relative(entity, from: path));

          resources.add(_packExternalFile(entity, fileMount));
        }
      }
    });

    return resources;
  }

  void _checkForDuplicates(List<_Resource> packedResources) {
    final paths = <String>{};
    for (final resource in packedResources) {
      if (paths.contains(resource.pathToMount)) {
        printerr(
            red('Duplicate resource at mount point: ${resource.pathToMount}'));
        dcliExit(1);
      }
      paths.add(resource.pathToMount);
    }
  }

  List<String> getExcludedPaths(SettingsYaml yaml, String path, int index) {
    final relativeExcludes =
        yaml.selectAsList('externals.external[$index].exclude') ?? <dynamic>[];

    final absoluteExcludes = <String>[];

    for (final exclude in relativeExcludes) {
      absoluteExcludes.add(truepath(path, exclude as String));
    }
    return absoluteExcludes;
  }
}

/// Base class used by all [PackedResource]s.
// ignore: one_member_abstracts
abstract class PackedResource {
  /// Create a [PackedResource] with
  /// the given b64encoded content.
  const PackedResource();

  /// The base64 encoded contents of the packed file.
  String get content;

  /// The checksum of the original file.
  /// You can use this value to see if packed file
  /// is different to a local file without having to unpack
  /// it.
  /// ```dart
  /// calculateHash('/path/to/local/file') == checksum
  /// ```
  String get checksum;

  /// The path to the original file relative to the
  /// packages resource directory.
  String get originalPath;

  /// Unpacks a resource saving it
  /// to the file at [pathTo].
  void unpack(String pathTo) {
    if (exists(pathTo) && !isFile(pathTo)) {
      throw ResourceException('The unpack target $pathTo must be a file');
    }
    final normalized = normalize(pathTo);
    if (!exists(dirname(normalized))) {
      createDir(dirname(normalized), recursive: true);
    }

    final file = waitForEx(File(normalized).open(mode: FileMode.write));

    try {
      for (final line in content.split('\n')) {
        if (line.trim().isNotEmpty) {
          waitForEx(file.writeFrom(base64.decode(line)));
        }
      }
    } finally {
      waitForEx<dynamic>(file.flush());
      file.close();
    }
  }
}

class _Resource {
  _Resource(this.pathToSource, String pathToGeneratedLibrary, this.className,
      {required this.pathToMount})
      : checksum = calculateHash(pathToSource).hexEncode() {
    this.pathToGeneratedLibrary = relative(pathToGeneratedLibrary,
        from: join(DartProject.self.pathToProjectRoot, 'lib'));
  }

  /// Path to the original file we are packing.
  final String pathToSource;

  /// The path to use when adding the resource to the
  /// registry. For files under the resource directory
  /// this is the same as [pathToSource].
  /// For external resources defined in pack.yaml this
  /// allows them to be mounted into the registry
  /// without collisions.
  final String pathToMount;

  /// The path to the dart library we generated to hold
  /// the encoded resource
  late final String pathToGeneratedLibrary;

  /// the generated class name used for this resource.
  final String className;

  /// A hash of the resource (pre packed) calculated by
  /// [calculateHash].
  /// This has can be used to check if the resource needs to
  /// be updated on the target system.
  /// Use calculateHash(pathToResource).hexEncode()
  /// to compare the checksum
  final String checksum;
}

/// Thrown when an error occurs trying to pack or unpack a resource file
class ResourceException extends DCliException {
  /// Thrown when an error occurs trying to pack or unpack a resource file
  ResourceException(super.message);
}
