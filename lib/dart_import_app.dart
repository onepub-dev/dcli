class DartImportApp {
  static DartImportApp _self = DartImportApp._internal();

  bool _debug = false;

  factory DartImportApp() {
    return _self;
  }

  DartImportApp._internal();

  void enableDebug() => _debug = true;

  bool get isdebugging => _debug;

  void debug(String line) {
    if (isdebugging) {
      print("DEBUG: ${line}");
    }
  }
}
