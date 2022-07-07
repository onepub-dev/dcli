@Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockSettings extends Mock implements Settings {}
