# Assets/Resources

Flutter allows you to bundle assets (graphics, sounds, config files...) along with your flutter application however dart cli applications do not have this ability.

DCli provides a set of asset management tools and an api to work around this limitation.

DCli refers to assets as 'resources' to differentiate them from flutter assets.

{% hint style="info" %}
If you use resources in a package that will be publish to pub.dev, remember there is a 10MB limit on the entire dart package.
{% endhint %}

DCli does this by packaging a resource into a .dart library and then providing an api that allows you to unpack the resources at runtime.

The `dcli pack` command base64 encodes each file and writes them as a multi-line string into a dart library under src/dcli/resource. The name of the dart library is randomly generated.

The pack command also creates a register of the packed libraries in src/dcli/resource/generated/resource\_registry.g.dart.

DCli expects all resources to located within your dart project under:

```
<project root>/resource
```

## Packing resources

To pack your resources you run:

```
dcli pack
```

The 'pack' command will scan the '\<project root>/resource' directory and all subdirectories. Each file that it finds will be converted to a dart library under:

```
<project root>/lib/src/dcli/resource/generated
```

Each library name is generated using a uuid of the form \<uuid>.g.dart

So the following resources:

```
<project root>/resource
                    /images/photo.png
                    /data/zips/installer.zip
```

Will result in to:

```
<project root>/lib/src/dcli/resource/generated
                            /resource_registry.g.dart
                            /aadafaasdf.g.dart
                            /aalwhkciyge.g.dart
```

The contents of each resource is base64 encoded into a multi-line string. So the photo.png.dart file will something look like:

````dart
class Bbbcdcbeeff extends PackedResource {
  /// PackedResource - local_batman.yaml
  const Bbbcdcbeeff();

  /// A hash of the resource (pre packed) calculated by
  /// [calculateHash].
  /// This hash can be used to check if the resource needs to
  /// be updated on the target system.
  /// Use :
  /// ```dart
  ///   calculateHash(pathToResource).hexEncode() == packResource.checksum
  /// ```
  /// to compare the checksum of the local file with
  /// this checksum
  @override
  String get checksum =>
      '14189a469cf7f78af8cd8d4e03815ea72412cea6cbe94779a8db9f736e147300';

  /// <package>/resource relative path to the original resource.
  @override
  String get originalPath => 'lphoto.png';

  @override
  String get content => '''
bG9nUGF0aDogL3Zhci9sb2cvYmF0bWFuLmxvZwoKZW1haWxfc2VydmVyX2hvc3Q6IGxvY2FsaG9zdApl
bWFpbF9zZXJ2ZXJfcG9ydDogMjUKZW1haW
````

## Resource Registry

As part of the packing process DCli also creates a registry of the packed resources. This is done by creating a dart library called:

&#x20;`<project root>/lib/src/dcli/resource/generated/resource_registry.g.dart`

The contents of the 'resource\_registry.dart' are of the form.

````dart
// ignore: prefer_relative_imports
import 'package:dcli/dcli.dart';
import 'Bbbcdcbeeff.g.dart';
import 'Bfbbcabcfec.g.dart';

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
  /// ResourceRegistry.resources['batman.yaml']
  ///     .unpack(join(HOME, '.mysettings', 'batman.yaml'));
  /// ```
  static const resources = <String, PackedResource>{
    'local_batman.yaml': Bbbcdcbeeff(),
    'docker_batman.yaml': Bfbbcabcfec(),
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

To unpack the resources on the target system use the `ResourceRegistry` class.

The `ResourceRegistory.resources` field is a map of the packed resources. The key is the path of the original resource file relative to the `resource` directory.&#x20;

Use the `.unpack` method to unpack your resource to a local path on the target system.

```dart
ResourceRegistry.resources['rules.yaml']
    .unpack(join(HOME, '.mysettings', 'rules.yaml'));
```

The values in the resources map is a `PackedResources`. The `PackedResource` includes a `checksum` field. The checksum can be used to see if the expanded resource is the same as the packed resource. You can use this to determine if you need to upgrade the unpacked resource with the latest packed one.



```dart
if (calculateHash(pathToResource).hexEncode() != packResource.checksum)
{
    /// unpack the latest version of the resource.
}
```

## External Resources

You can also pack resources that are external to your project by creating a pack.yaml file under your project's tool/dcli director.

The pack.yaml file allows you to specify a number of files and/or directories and their virtual mount point within the resource directory.

```yaml
externals:
  - external:
    path: ../template/basic
    mount: template/basic
  - external:
    path: ../template/cmd_args
    mount: template/cmd_args
  - external:
    path: ../template/find
    mount: template/find
  - external:
    path: ../template/hello_world
    mount: template/hello_world
```

The path for each external may be a file or a directory. If path is a directory then the directory is included recursively.

The mount point is a virtual location within the resource directory. It may not overlap any actual files/paths in the resource directory.

To unpack external resources you use the mount point as the key into the ResourceRegistry.

## Limits

If you plan on publishing your project to pub.dev be aware that pub.dev has a maximum package size of 10MB.

The base64 encoding process increases the file size by about 33%.

For apps that you deploy locally the limits are not documented but are probably constrained by your systems memory - so fairly large.

&#x20;

## Automating packing of resources

If you use pub\_release to publish to pub.dev then you can create a pre-release hook to have pub\_release package your resources.
