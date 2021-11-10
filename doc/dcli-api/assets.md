# Assets/Resources

Flutter allows you to bundle assets (graphics, sounds, config files...) along with your flutter application however dart cli applications do not have this ability.

DCli provides a set of asset management tools and an api to work around this limitation.

DCli refers to assets as 'resources' to differentiate them from flutter assets.

{% hint style="info" %}
If you use resources in a package that will be publish to pub.dev, remember there is a 10MB limit on the entire dart package.
{% endhint %}

DCli does this by packaging an resource into a .dart library and then providing an api that allows you to unpack the resources at runtime.

DCli expects all resources to located within your dart project under:

```
<project root>/resources
```

## Packing resources

To pack your resources you run:

```
dcli pack
```

The 'pack' command will scan the '\<project root>/resources' directory and all subdirectories. Each file that it finds will be converted to a dart library under:

```
<project root>/lib/src/dcli/resources/generated
```

Each library name is generated using a uuid of the form \<uuid>.g.dart

So the following resources:

```
<project root>/resources
                    /images/photo.png
                    /data/zips/installer.zip
```

Will result in to:

```
<project root>/lib/src/dcli/resources/generated
                            /resource_registry.g.dart
                            /aadafaasdf.g.dart
                            /aalwhkciyge.g.dart
```

The contents of each resource is base64 encoded into a multi-line string. So the photo.png.dart file will something look like:

```
class Bcaaebbbbefe extends PackedResource {

  // PackedResource
  const Bcaaebbbbefe() : super(
    '''
/9j/4aE0RXhpZgAASUkqAAgAAAANAAABAwABAAAAwA8AAAEBAwABAAAA0AsAAA8BAgAHAAAAqgAAABAB
AgAIAAAAsQAAABIBAwABAAAAAQAAABoBBQABAAAAuQAAABsBBQABAAAAwQAAACgBAwABAAAAAgAAADEB
AgAVAAAAyQAAADIBAgAUAAAA3gAAABMCAwABAAAAAQAAAGmHBAABAAAA8gAAACWIBAABAAAAgwMAAGQE
AABHb29nbGUAUGl4ZWwgNQBIAAAAAQAAAEgAAAABAAAASERSKyAxLjAuMzg4Nzg0NzYyemQAMjAyMTox
  ''');
}
```

## Resource Registry

As part of the packing process DCli also creates a registry of the packed resources. This is done by creating a dart library called:

&#x20;`<project root>/lib/src/dcli/resources/generated/resource_registry.g.dart`

The contents of the 'resource\_registry.dart' are of the form.

````
import 'package:dcli/dcli.dart';
import 'Bdcdfbdfdfa.g.dart';
import 'Bffeaaac.g.dart';

/// GENERATED -- GENERATED
/// 
/// DO NOT MODIFIY
/// 
/// This script is generated via [Resource.pack()].
/// 
/// GENERATED - GENERATED

class ResourceRegistry {

  /// Map of the packed files.
  /// Use the path of a packed file (relative to the resource directory)
  /// to access the packed resource and then call [PackedResource].unpack()
  /// to unpack the file.
  /// ```dart
  /// ResourceRegistry.resources['rules.yaml'].unpack(join(HOME, '.mysettings', 'rules.yaml'));
  /// ```
  static const Map<String, PackedResource> resources = {
      'test.me' : Bdcdfbdfdfa(),
      'PXL_20211104_224740653.jpg' : Bffeaaac(),
    };
  }
  
````

## Unpacking resources

DCli provides an api that allows your script to unpack its resources at run time.

```
ResourceRegistry().resources['<relative filename>'].unpack(String localPath)
```

The `resources` field is a map and the key to the map is the original path to the packed file 'relative' to the resources directory.

e.g.

```
  const filename = 'PXL_20211104_224740653.jpg';
  
  final jpegResource = ResourceRegistry.resources[filename];
  
  final pathToConfigs = join(HOME, '.myapp');
  if (!exists(pathToConfigs)
  {
    createDir(pathToConfigs);
  }
  jpegResource!.unpack(join(pathToConfigs, filename);

```

## Automating packing of resources

If you use pub\_release to publish to pub.dev then you can create a pre-release hook to have pub\_release package your resources.
