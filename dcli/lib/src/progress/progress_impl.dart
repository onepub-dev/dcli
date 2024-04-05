/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

abstract class ProgressImpl {
  int? exitCode;

  /// adds the [data] to the stdout controller
  void addToStdout(List<int> data);

  /// adds the [data] to the stderr controller
  void addToStderr(List<int> data);

  // for progresses that need to be cleaned up such
  // as streams - I think.
  void close();
}
