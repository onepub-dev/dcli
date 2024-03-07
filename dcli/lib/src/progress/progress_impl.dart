/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

abstract class ProgressImpl {
  int? exitCode;

  /// adds the [line] to the stdout controller
  void addToStdout(String line);

  /// adds the [line] to the stderr controller
  void addToStderr(String line);

  // for progresses that need to be cleaned up such
  // as streams - I think.
  void close();
}
