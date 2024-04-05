import '../../dcli.dart';

mixin ProgressMixin implements Progress {
  // @override
  // int get exitCode => throw UnimplementedError();

  /// Returns the first line from the command or
  /// null if no lines where returned
  @override
  String? get firstLine => lines.first;

  @override
  void forEach(void Function(String line) action) {
    for (final line in lines) {
      action(line);
    }
  }

  @override
  Stream<List<int>> get stream => throw UnimplementedError();

  @override
  List<String> toList() => lines;

  @override
  String toParagraph() => lines.join(eol);
}
