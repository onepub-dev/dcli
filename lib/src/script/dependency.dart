import 'package:equatable/equatable.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';
import '../../src/pubspec/dep_ref_extension.dart';

class Dependency extends Equatable {
  final String name;
  final DependencyReference reference;

  const Dependency(this.name, this.reference);

  static Dependency fromHosted(String name, String version) {
    var reference = HostedReference(VersionConstraint.parse(version));

    return Dependency(name, reference);
  }

  static Dependency fromPath(String name, String path) {
    var reference = PathReference(path);

    return Dependency(name, reference);
  }

  static Dependency fromLine(String line) {
    Dependency dep;

    var parts = line.split(' ');
    if (parts.length == 3) {
      // dep = Dependency(parts[1], parts[2]);
    }
    return dep;
  }

/*  Dependency.fromYaml(YamlNode node)
      : name = extractName(node),
        version = extractVersion(node);
*/
/*  static String extractVersion(YamlNode node) {
    print(node);
  }

  static String extractName(YamlNode node) {
    print(node);
  }
*/
  @override
  List<Object> get props => [name, reference];

  @override
  String toString() {
    return '${reference.rehydrate(this)}';
  }

  String rehydrate() {
    return reference.rehydrate(this);
  }
}
