@Timeout(Duration(seconds: 600))
import 'package:dshell/src/functions/env.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockEnv extends Mock implements Env {}
