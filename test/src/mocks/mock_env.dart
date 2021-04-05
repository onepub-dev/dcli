@Timeout(Duration(seconds: 600))
import 'package:dcli/src/functions/env.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockEnv extends Mock implements Env {}
