import 'dart:developer';
import 'dart:isolate';

/// Returns the current Isolate's ID - just the numeric component.
int get isolateID {
  String? isolateString;

  isolateString = Service.getIsolateId(Isolate.current);
  int? isolateId;
  if (isolateString != null) {
    isolateString = isolateString.replaceAll('/', '_');
    isolateString = isolateString.replaceAll(r'\', '_');
    if (isolateString.contains('_')) {
      /// just the numeric value.
      isolateId = int.tryParse(isolateString.split('_')[1]);
    }
  }
  return isolateId ??= Isolate.current.hashCode;
}
