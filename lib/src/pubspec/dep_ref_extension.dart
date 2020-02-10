import 'package:dshell/src/script/command_line_runner.dart';
import 'package:dshell/src/script/dependency.dart';
import 'package:pubspec/pubspec.dart';

extension DependencyReferenceEx on DependencyReference {
  String rehydrate(Dependency dependency) {
    if (dependency.reference is HostedReference) {
      return (dependency.reference as HostedReference).rehydrate(dependency);
    } else if (dependency.reference is GitReference) {
      return (dependency.reference as GitReference).rehydrate(dependency);
    } else if (dependency.reference is PathReference) {
      return (dependency.reference as PathReference).rehydrate(dependency);
    } else if (dependency.reference is ExternalHostedReference) {
      return (dependency.reference as ExternalHostedReference)
          .rehydrate(dependency);
    }

    throw InvalidArguments(
        'Unknown dependency type: ${dependency.runtimeType}');
  }
}

extension HostedReferenceExt on HostedReference {
  String rehydrate(Dependency dependency) {
    return '${dependency.name}: ${versionConstraint.toString()}';
  }
}

extension GitReferenceExt on GitReference {
  String rehydrate(Dependency dependency) {
    var expanded = '''${dependency.name}: 
  git: 
    url: ${url}''';

    if (ref != null) {
      expanded += '\n    ref: ${ref}';
    }

    return expanded;
  }
}

extension PathReferenceExt on PathReference {
  String rehydrate(Dependency dependency) {
    var expanded = '''${dependency.name}: 
    path: ${path}''';

    return expanded;
  }
}

extension ExternalHostedReferenceExt on ExternalHostedReference {
  String rehydrate(Dependency dependency) {
    var expanded = '''${dependency.name}: 
hosted:
  name: ${name}
  url: ${url}
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
