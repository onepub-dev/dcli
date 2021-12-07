import '../../dcli.dart';

/// Creates a project from a template
class ProjectCreator {
  /// Creates a project based on a template.
  DartProject createFromTemplate(String pathToTemplate, String pathToProject) {
    if (!exists(pathToProject)) {
      createDir(pathToProject, recursive: true);
    }

    copyTree(pathToTemplate, pathToProject);

    final projectName = basename(pathToProject);
    final pathToPubspec = join(pathToProject, 'pubspec.yaml');
    replace(pathToPubspec, 'name: projectname', 'name: $projectName');

    return DartProject.fromPath(pathToProject, search: false);
  }
}
