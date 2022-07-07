/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart';

/// Base class for functions that return some type
/// of Progres.
abstract class InternalProgress {
  /// Abstract method which should be overriden
  /// by the derived class to call  [action]
  /// for each line in the derived classes perview.
  void forEach(LineAction action);

  /// Returns the list of lines by
  /// calliing [forEach].
  List<String> toList() {
    final list = <String>[];

    forEach(list.add);

    return list;
  }
}
