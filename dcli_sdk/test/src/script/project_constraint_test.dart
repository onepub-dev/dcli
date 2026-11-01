import 'dart:io';

import 'package:dcli/src/script/dart_project.dart';
import 'package:dcli_sdk/src/dcli/resource/generated/resource_registry.g.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_manager/pubspec_manager.dart';
import 'package:test/test.dart';

void main() {
  test('embedded project template preserves published dependency versions', () {
    final temp = Directory.systemTemp.createTempSync('dcli-template-');
    try {
      final pubspecPath = p.join(temp.path, 'pubspec.yaml');
      ResourceRegistry.resources['template/project/full/pubspec.yaml']!
          .unpack(pubspecPath);
      final template = PubSpec.loadFromPath(pubspecPath);
      final originalCore =
          (template.dependencies['dcli_core']! as DependencyVersioned)
              .versionConstraint;
      expect(originalCore, contains('10.4.0'));
      fixTemplatePubspec('sample', template, pubspecPath);

      final result = PubSpec.loadFromPath(pubspecPath);
      expect(
        (result.dependencies['dcli']! as DependencyVersioned)
            .versionConstraint,
        '10.4.3',
      );
      expect(
        (result.dependencies['dcli_core']! as DependencyVersioned)
            .versionConstraint,
        originalCore,
      );
    } finally {
      temp.deleteSync(recursive: true);
    }
  });
}
