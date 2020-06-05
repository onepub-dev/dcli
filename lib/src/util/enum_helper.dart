
///
/// Provides a collection of methods that help when working with
/// enums.
///
class EnumHelper {
  /// returns an enum based on its index.
  static T getByIndex<T>(List<T> values, int index) {
    return values.elementAt(index - 1);
  }

  /// returns the index of a enum value.
  static int getIndexOf<T>(List<T> values, T value) {
    return values.indexOf(value);
  }

  ///
  /// Returns the Enum name without the enum class.
  /// e.g. DayName.Wednesday becomes Wednesday.
  /// By default we recase the value to Title Case.
  /// You can pass an alternate method to control the format.
  ///
  static String getName<T>(T enumValue) {
    var name = enumValue.toString();
    var period = name.indexOf('.');

    return _titleCase(name.substring(period + 1));
  }

  /// formats an enum value use titleCase.
  static String _titleCase(String word) {
    return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
  }

  /// returns a enum based on its name.
  static T getEnum<T>(String enumName, List<T> values) {
    var cleanedName = _titleCase(enumName);
    for (var i = 0; i < values.length; i++) {
      if (cleanedName == getName(values[i])) {
        return values[i];
      }
    }
    throw Exception("$cleanedName doesn't exist in the list of enums $values");
  }
}
