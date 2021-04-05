@Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockSettings extends Mock implements Settings {}
