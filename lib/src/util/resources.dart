#! /usr/bin/env dcli

import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:uuid/uuid.dart';

import '../../dcli.dart';

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
  static final String _resourceRoot = join('resources');
  static final String _generatedRoot =
      join('lib', 'src', 'dcli', 'resources', 'generated');
  static final String _pathToRegistry =
      join(_generatedRoot, 'resource_registry.g.dart');

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
    final resources = find('*', workingDirectory: resourceRoot).toList();

    /// clear out an old generated files
    /// as we use UUIDs if we didn't do this the
    /// directory would keep growing.
    if (exists(_generatedRoot)) {
      deleteDir(_generatedRoot);
    }
    createDir(_generatedRoot, recursive: true);

    final packedResources = _packResources(resources);

    print(' - generating registry');
    _writeRegistry(packedResources);
    print(green('Pack complete'));

    // if (!overwrite && exists(pathToDartLibrary)) {
    //   throw ResourceException(
    //       'The target dart libarary ${truepath(pathToDartLibrary)}'
    //       ' already exists.');
    // }
    // for (final pathToResource in pathToResources) {
    //   if (!exists(pathToResource)) {
    //     throw ResourceException(
    //         'The resource file $pathToResource does not exist');
    //   }
    //   _packAssets(pathToDartLibrary, pathToResources);
    // }
  }

  List<_Resource> _packResources(List<String> pathToResources) {
    final resources = <_Resource>[];

    for (final pathToResouce in pathToResources) {
      final className = _generateClassName;

      final pathToGeneratedLibrary = join(_generatedRoot, '$className.g.dart');
      print(' - packing: $pathToResouce into $pathToGeneratedLibrary');

      final resource =
          _packResource(pathToResouce, pathToGeneratedLibrary, className);
      resources.add(resource);
    }
    return resources;
  }

  /// Encode and write the resource into a dart library.
  _Resource _packResource(
      String pathToResource, String pathToGeneratedLibrary, String className) {
    final to = File(pathToGeneratedLibrary).openWrite();
    try {
      /// write the header
      to.write(
        '''
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

  /// PackedResource - ${relative(pathToResource, from: 'resources')}
  const $className() : super(
     \'''
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

      /// Write the tail
      to.write(
        '''
  \'\'\');
}
    ''',
      );
      waitForEx<dynamic>(to.flush());
    } finally {
      to.close();
    }

    return _Resource(pathToResource, pathToGeneratedLibrary, className);
  }

  bool _isAlpha(int char) =>
      (char >= 'a'.codeUnits[0] && char <= 'z'.codeUnits[0]) ||
      (char >= 'A'.codeUnits[0] && char <= 'Z'.codeUnits[0]);

  /// generates a random class name
  String get _generateClassName {
    var className = '';

    // keep generating uuids until we get one that contains at least one
    // alpha character
    while (className.isEmpty) {
      final uuid = const Uuid().v4();
      for (final char in uuid.codeUnits) {
        if (_isAlpha(char)) {
          var alpha = String.fromCharCode(char);

          if (className.isEmpty) {
            /// make the class name camelcase.
            alpha = alpha.toUpperCase();
          }
          className += alpha;
        }
      }
      if (exists(join(generatedRoot, '$className.g.dart'))) {
        // start again.
        className = '';
      }
    }
    return className;
  }

  void _writeRegistry(List<_Resource> resources) {
    final registryFile = File(_pathToRegistry).openWrite();
    try {
      // import 'package:dcli/src/dcli/resources/generated/Bbcded.g.dart';
      /// Write the header
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
  static const Map<String, PackedResource> resources = {
''',
        );
      }

      /// Write each resource into the map
      for (final resource in resources) {
        registryFile.write('''
      '${relative(resource.pathToSource, from: resourceRoot)}' : ${resource.className}(),
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

  // void _packAssets(String pathToDartLibrary, List<String> pathToResources) {
  //   final content = _buildDartLibrary(pathToDartLibrary, pathToResources);

  //   print('Writing assets to $pathToDartLibrary');
  //   pathToDartLibrary.write(content);
  // }

  /// Build the contents of the  dart library packing each resource
  /// into a separate method of a class.
  ///
  /// The class name is taken from the passed dart library name so
  /// my_resource.dart yeilds the class name MyResource
  ///
  /// Each method contains a string which is the contents of the resource
  /// encoded as a string.
  ///
  ///
  /// At run time use MyResource.unpack() to unpack
  /// each resource.
//   String _buildDartLibrary(
//       String pathToDartLibrary, List<String> pathToResources) {
//     final resources = <String>[];

//     final className = _deriveClassName(pathToDartLibrary);

//     final content = StringBuffer(
//       '''
// // ignore: prefer_relative_imports
// import 'package:dcli/dcli.dart';

// /// GENERATED -- GENERATED
// ///
// /// DO NOT MODIFIY
// ///
// /// This script is generated via [Resource.pack()].
// ///
// /// GENERATED - GENERATED

// class $className {

//     /// Creates a $className that will unpack its files into [targetPath]
//     /// when the [unpack] method is called.
//     $className(this.targetPath);

//     /// The path the resources will be expanded into.
//     String targetPath;

// ''',
//     );

//     print('packing resources');
//     for (final pathToResource in pathToResources) {
//       print('packing $pathToResource');

//       /// Write the content of each resource into a method.
//       content.write(
//         '''
// \t\t/// Resource for ${_buildMethodName(pathToResource)}
// \t\t// ignore: non_constant_identifier_names
// \t\tvoid ${_buildMethodName(pathToResource)}() {
//       join(targetPath, '${basename(pathToResource)}').write(
//           // ignore: unnecessary_raw_strings
//          r\'\'\'
// ${waitForEx(_base64Encode(pathToResource)).toList().join('\n')}\'\'\',);
//     }

// ''',
//       );

//       resources.add('\t\t\t${_buildMethodName(pathToResource)}();\n');
//     }

//     /// Create the 'unpack' method which when called will
//     /// unpack each of the assets.
//     content.write(
//       '''
// /// Unpack all templates.
// \t\tvoid unpack() {
// ''',
//     );

//     resources.forEach(content.write);
//     content
//       ..write(
//         '''
//   }
// ''',
//       )
//       ..write(
//         '''
// }''',
//       );

//     return content.toString();
//   }

//   String _buildMethodName(String file) {
//     var _file = file;
//     if (_file.endsWith('.dcli_template')) {
//       _file = basenameWithoutExtension(_file);
//     }

//     return basenameWithoutExtension(_file);
//   }

//   List<_Resource> _buildResourceArray(List<String> pathToResources)
//   {
//     final map = <_Resource>[];

//     for (final pathToResource in pathToResources) {
//       print('packing $pathToResource');

//       join(targetPath, basename(pathToResource)).write(
//           // ignore: unnecessary_raw_strings
//          r\'\'\'
// ${waitForEx(_base64Encode(pathToResource)).toList().join('\n')}\'\'\',);
//     }

//   }

  // /// Converts a dart library name into a class name
  // /// e.g.
  // /// my_asset.dart -> MyAsset
  // String _deriveClassName(String pathToDartLibrary) {
  //   var className = '';

  //   var toUpper = true;

  //   for (final char in pathToDartLibrary.codeUnits) {
  //     if (char.toString() == '_') {
  //       toUpper = true;
  //       continue;
  //     }

  //     if (toUpper) {
  //       className += char.toString().toUpperCase();
  //     }
  //   }
  //   return className;
  // }

  // Future<List<String>> _base64Encode(String pathToResource) async {
  //   final encodedLines = <String>[];

  //   final reader = ChunkedStreamReader(File(pathToResource).openRead());

  //   /// ignore: literal_only_boolean_expressions
  //   while (true) {
  //     final data = await reader.readChunk(60);
  //     encodedLines.add(base64.encode(data));
  //     if (data.length < 60) {
  //       break;
  //     }
  //   }

  //   return encodedLines;
  // }
}

/// Base class used by all [PackedResource]s.
// ignore: one_member_abstracts
class PackedResource {
  /// Create a [PackedResource] with
  /// the given b64encoded content.
  const PackedResource(this._content);

  final String _content;

  /// Unpacks a resource saving it
  /// to [pathTo]
  void unpack(String pathTo) {
    final file = waitForEx(File(pathTo).open(mode: FileMode.write));

    try {
      for (final line in _content.split('\n')) {
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
  _Resource(this.pathToSource, String pathToGeneratedLibrary, this.className) {
    this.pathToGeneratedLibrary = relative(pathToGeneratedLibrary,
        from: join(DartProject.self.pathToProjectRoot, 'lib'));
  }

  /// Path to the original file we are packing.
  final String pathToSource;

  /// The path to the dart library we generated to hold
  /// the encoded resource
  late final String pathToGeneratedLibrary;

  /// the generated class name used for this resource.
  final String className;
}

/// Thrown when an error occurs trying to pack or unpack a resource file
class ResourceException extends DCliException {
  /// Thrown when an error occurs trying to pack or unpack a resource file
  ResourceException(String message) : super(message);
}
