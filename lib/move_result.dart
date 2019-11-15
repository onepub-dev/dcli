import 'dart:io';

import 'library.dart';

class MoveResult {
  Library _library;
  File tmpFile;
  int changeCount = 0;

  MoveResult(Library library, this.tmpFile) {
    _library = library;
  }

  Library get library => _library;
}
