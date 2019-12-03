import 'package:dshell/pubspec/dependencies_mixin.dart';
import 'package:dshell/pubspec/pubspec.dart';
import 'package:dshell/script/my_yaml.dart';
import 'package:dshell/script/project.dart';

import 'package:path/path.dart' as p;

class PubSpecVirtual extends PubSpec with DependenciesMixin {
  // The script this PubSpec is associated with.
  PubSpec sourcePubSpec;

  MyYaml yaml;

  ///
  /// Create a virtual pubspec from an existing pubspec
  /// which could have been an default pubspec,
  /// an annotation or an actual file based pubspec.yaml.
  PubSpecVirtual.fromPubSpec(PubSpec sourcePubSpec) {
    yaml = sourcePubSpec.yaml;
  }

  /// Load the pubspec.yaml from the virtual project directory.
  PubSpecVirtual.loadFromProject(VirtualProject project) {
    final String pubSpecPath = p.join(project.path, "pubspec.yaml");

    yaml = MyYaml.loadFromFile(pubSpecPath);
  }
}
