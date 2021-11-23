# dcli pack

The dcli pack command allows you to pack resources (images, config files etc) into your cli app.

Whilst flutter allows you to include assets in a dart executable no such feature exists for dart cli apps. The dcli pack command is designed to fill that void.

A resource is just a file that you want to ship with your package.

To pack a resource in you cli app create a 'resource' directory in the root of your project package.

Place each file in the resource directory.

Run `dcli pack`.

The pack command base64 encodes each file and writes them as a multi-line string into a dart library under src/dcli/resources. The name of the dart library is randomly generated.

The pack command also creates a register of the packed libraries in src/dcli/resources/resource\_registry.g.dart.

To unpack the resources on the target system use the ResourceRegistry class.

The `resources` field is a map of the packed resources. The key is the path of the original resource file relative to the `resources` directory.&#x20;

```dart
ResourceRegistry.resources['rules.yaml']
    .unpack(join(HOME, '.mysettings', 'rules.yaml'));
```

The values in the resources map is a ``PackedResources. The PackedResource includes a `checksum` field. The checksum can be used to see if the expanded resource is the same as the packed resource. You can use this to determine if you need to upgrade the unpacked resource with the latest packed one.`` &#x20;



```dart
if (calculateHash(pathToResource).hexEncode() != packResource.checksum)
{
    /// unpack the latest version of the resource.
}
```

## Limits

If you plan on publishing your project to pub.dev be aware that pub.dev has a maximum package size of 10MB.

The base64 encoding process increases the file size by about 33%.

For apps that you deploy locally the limits are not documented but are probably constrained by your systems memory - so fairly large.

&#x20;
