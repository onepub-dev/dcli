class MailHogException implements Exception {
  MailHogException(this.exitCode, this.message, {required this.showUsage});

  int exitCode;
  String message;
  bool showUsage;
}
