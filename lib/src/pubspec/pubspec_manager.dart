import '../script/dependency.dart';
import '../script/virtual_project.dart';

import 'global_dependencies.dart';
import 'pubspec.dart';
import 'pubspec_annotation.dart';
import 'pubspec_default.dart';
import 'pubspec_file.dart';
import 'pubspec_virtual.dart';

/// Provides a collection of methods to assist with managing a pubspec.
class PubSpecManager {
  final VirtualProject _project;

  /// the pubsec from the scripts root directory
  /// (if it exists)
  PubSpec packageSpec;

  /// Create a manager for the given [_project].
  PubSpecManager(this._project);

  /// Creates a virtual pubspec.yaml for the passed project.
  ///
  /// 1) Searches for an annotation pubspec: if found uses this as a base
  /// 2) if 1 failes looks for a local pubspec.yaml ; if found use this as a base
  /// 3) if no pubspec then a default base is created.
  ///
  /// Dependency injection occurs.
  ///
  /// The resulting pubspec is written to the project directory.
  ///
  void createVirtualPubSpec() {
    var script = _project.script;
    PubSpec sourcePubSpec;

    PubSpec defaultPubspec = PubSpecDefault(script);
    var annotation = PubSpecAnnotation.fromScript(script);

    if (!annotation.annotationFound()) {
      if (script.hasLocalPubspecYaml()) {
        sourcePubSpec = PubSpecFile.fromScript(script);
      } else {
        sourcePubSpec = defaultPubspec;
      }
    } else {
      sourcePubSpec = annotation;
    }

    PubSpec pubSpec = PubSpecVirtual.fromPubSpec(sourcePubSpec);

    var resolved = resolveDependencies(pubSpec, defaultPubspec);

    pubSpec.dependencies = resolved;

    pubSpec.saveToFile(_project.projectPubspecPath);
  }

  //   bool isCleanRequired() {
  //   bool cleanRequried = false;

  //   DateTime scriptLastModifed = lastModified(project.script.path);
  //   DateTime virtualPubSpecLastModified = lastModified(project.pubspec.path);

  //   if (scriptLastModifed != virtualLastModified) {
  //     /// last modified is not the same so now check the contents

  //     if (annotationSpec != virtualSpec) {
  //       _loadAnnotationYaml(project);
  //       _loadVirtualYaml(project);
  //       cleanRequried = true;
  //     }
  //   }
  //   return cleanRequried;
  // }

  /// Loads dependencies from
  /// virtual pubspec
  /// global dependencies
  /// default dependencies
  ///
  /// and returns a resolve list.
  ///
  /// To resolve a list we de-duplicate any entries
  /// by name.
  /// If there are duplicates the 'preferred' entrie
  /// is selected.
  ///
  List<Dependency> resolveDependencies(
      PubSpec selected, PubSpec defaultPubSpec) {
    var resolved = <Dependency>[];

    // Start form least important to most imporant
    // Note: the defaultPubSpec no longer contains dependencies
    // but I've left this here incase it changes again.
    var defaultDependencies = defaultPubSpec.dependencies;
    var globalDependencies = _getGlobalDependencies();

    // take the preferred ones from global and default
    resolved = _resolve(globalDependencies, defaultDependencies);

    var pubspecDependencies = selected.dependencies;

    // If the default pubspec is also the selected one then
    // we MUST NOT re-resolve otherwise the defaults will take
    // precendence over the global dependencies which is against the rules.
    if (selected != defaultPubSpec) {
      // take the preferred ones from pubspec and the above
      resolved = _resolve(pubspecDependencies, resolved);
    }

    return resolved;
  }

  List<Dependency> _getGlobalDependencies() {
    var gd = GlobalDependencies();
    return gd.dependencies;
  }

  List<Dependency> _resolve(List<Dependency> preferred, List<Dependency> base) {
    var resolved = <Dependency>[];
    for (var basic in base) {
      // if there is a matching preferred item then use that.
      var add = preferred.firstWhere(
          (preference) => preference.name == basic.name,
          orElse: () => basic);

      resolved.add(add);
    }

    // add any preferred items that simply arn't in the base
    for (var preference in preferred) {
      // check inf the preference is already in the list.
      var found = resolved.firstWhere(
          (element) => element.name == preference.name,
          orElse: () => null);
      if (found == null) resolved.add(preference);
    }
    return resolved;
  }
}
