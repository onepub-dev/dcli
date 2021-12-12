# DCli Pack

The dcli pack command allows you to pack resources (images, config files etc) into your cli app.

Whilst flutter allows you to include assets in a dart executable no such feature exists for dart cli apps. The dcli pack command is designed to fill that void.

A resource is just a file that you want to ship with your package.

To pack a resource in you cli app create a 'resource' directory in the root of your project package.

Place each file in the resource directory.

Run `dcli pack`.

The pack command base64 encodes each file and writes them as a multi-line string into a dart library under src/dcli/resources. The name of the dart library is randomly generated.

The pack command also creates a register of the packed libraries in src/dcli/resource/generated/resource\_registry.g.dart.

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
