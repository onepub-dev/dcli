/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_sdk/src/script/entry_point.dart';
import 'package:test/test.dart';

void main() {
  test('entry point ...', () async {
    await EntryPoint().process(['--verbose', 'create']);
  });
}
