// ignore: import_of_legacy_library_into_null_safe
// ignore: import_of_legacy_library_into_null_safe
import 'package:pubspec/pubspec.dart';
import '../script/command_line_runner.dart';
import 'dependency.dart';

/// adds rehydrate method to DependencyReference and friends.
extension DependencyReferenceEx on DependencyReference? {
  /// expands the dependancy to its yaml form.
  String rehydrate(Dependency dependency) {
    if (dependency.reference is HostedReference) {
      return (dependency.reference as HostedReference?)!.rehydrate(dependency);
    } else if (dependency.reference is GitReference) {
      return (dependency.reference as GitReference?)!.rehydrate(dependency);
    } else if (dependency.reference is PathReference) {
      return (dependency.reference as PathReference?)!.rehydrate(dependency);
    } else if (dependency.reference is ExternalHostedReference) {
      return (dependency.reference as ExternalHostedReference?)!
          .rehydrate(dependency);
    }

    throw InvalidArguments(
        'Unknown dependency type: ${dependency.runtimeType}');
  }
}

///
extension HostedReferenceExt on HostedReference {
  /// expands the dependancy to its yaml form.
  String rehydrate(Dependency dependency) {
    String? constraint;
    if (versionConstraint == null) {
      constraint = 'any';
    } else {
      constraint = versionConstraint.toString();
    }

    return '${dependency.name}: $constraint';
  }
}

///
extension _GitReferenceExt on GitReference {
  /// expands the dependancy to its yaml form.
  String rehydrate(Dependency dependency) {
    var expanded = '''
${dependency.name}: 
  git: 
    url: $url''';

    if (ref != null) {
      expanded += '\n    ref: $ref';
    }

    return expanded;
  }
}

///
extension _PathReferenceExt on PathReference {
  /// expands the dependancy to its yaml form.
  String rehydrate(Dependency dependency) {
    final expanded = '''
${dependency.name}: 
    path: $path''';

    return expanded;
  }
}

///
extension _ExternalHostedReferenceExt on ExternalHostedReference {
  /// expands the dependancy to its yaml form.
  String rehydrate(Dependency dependency) {
    final expanded = '''
${dependency.name}: 
hosted:
  name: $name
  url: $url
version: ${versionConstraint.toString()}''';

    return expanded;
  }
}

// extension SdkReferenceExt on SdkReference {
//   String rehydrate(Dependency dependency) {
//     var expanded = '''${dependency.name}:
//   sdk: ${sdk}''';

//     return expanded;
//   }
// }
