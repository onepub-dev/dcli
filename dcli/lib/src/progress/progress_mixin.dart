import '../../dcli.dart';

mixin ProgressMixin implements Progress {
  // @override
  // int get exitCode => throw UnimplementedError();

  /// Returns the first line from the command or
  /// null if no lines were returned
  @override
  String? get firstLine => lines.firstOrNull;

  @override
  void forEach(void Function(String line) action) {
    for (final line in lines) {
      action(line);
    }
  }

    /// Throws [UnimplementedError].
  /// @Throwing(UnimplementedError)
  @override
  Stream<List<int>> get stream => throw UnimplementedError();

  @override
  List<String> toList() => lines;

  @override
  String toParagraph() => lines.join(eol);
}
