import 'flags.dart';

class SelectedFlags {
  factory SelectedFlags() => _self;

  SelectedFlags._();
  static final SelectedFlags _self = SelectedFlags._();
  final _selectedFlags = <String, Flag>{};

  /// the list of global flags selected via the cli when dcli
  /// was started.
  List<Flag> get selectedFlags => _selectedFlags.values.toList();

  /// A method to test with a specific global
  /// flag has been set.
  ///
  /// This is for interal useage.
  bool isFlagSet(Flag flag) => _selectedFlags.containsValue(flag);

  /// A method to set a global flag.
  void setFlag(Flag flag) {
    _selectedFlags[flag.name] = flag;
  }
}
