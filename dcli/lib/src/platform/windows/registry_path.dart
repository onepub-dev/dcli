import 'package:path/path.dart' as p;

/// User PATH operations with explicit storage and notification dependencies.
/// Tests supply memory storage, so they never need the real Environment key.
class RegistryPath {
  RegistryPath({required this.read, required this.write, required this.notify});

  final String Function() read;
  final void Function(String value) write;
  final void Function() notify;

  final _paths = p.Context(style: p.Style.windows);

  bool contains(String path) => _contains(path, read().split(';'));

  bool _contains(String path, List<String> paths) =>
      paths.map(_paths.canonicalize).contains(_paths.canonicalize(path));

  void append(String path) {
    final paths = read().split(';');
    if (!_contains(path, paths)) {
      replace([...paths, path]);
    }
  }

  void prepend(String path) {
    final paths = read().split(';');
    if (!_contains(path, paths)) {
      replace([path, ...paths]);
    }
  }

  void replace(List<String> paths) {
    write(paths.join(';'));
    notify();
  }
}
