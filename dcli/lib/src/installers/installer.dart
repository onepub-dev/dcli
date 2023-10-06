import 'package:meta/meta.dart';
import 'package:scope/scope.dart';

/// During testing we want to install dcli from source.
@visibleForTesting
final installFromSourceKey = ScopeKey<bool>();
