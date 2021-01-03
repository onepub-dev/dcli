# Assets

Assets are coming soon!

Flutter allows you to bundle assets \(graphics, sounds, ...\) along with your flutter application however dart cli applications do not have this ability.

DCli provides a set of asset management tools and an api to work around this limitation.

{% hint style="info" %}
If you use these tools to package assets into a package that you are going to publish to pub.dev remember there is a 10MB limit.
{% endhint %}

DCli does this by packaging an asset into a .dart library and then providing an api that allows you to unpack the assets at runtime.

DCli expects all assets to located within your dart project under:

```text
<project root>/asset
```

## Pack assets

To package your assets you run:

```text
dcli pack
```

The 'pack' command will scan the 'asset' directory and all subdirectories. Each file that it finds will be converted to a dart library under:

```text
<project root>/lib/src/asset
```

So the following assets:

```text
<project root>/asset
                    /images/photo.png
                    /data/zips/installer.zip
```

Will be converted to:

```text
<project root>/lib/src/asset
                            /images/photo.png.dart
                            /data/zips/installer.zip.dart
```

The contents of each asset are base64 encoded into a multi-line string. So the photo.png.dart file will look like:

```text
/// photo.png.dart
stat const name = 'photo.png';
static const content = '''ASFASF97AA09723NASDHASDH

...
''';

```

## Asset listing

As part of the packing process DCli also creates a registry of the assets packed. This is done by creating a dart library called 'asset\_registry.dart'. The contents of the 'asset\_registry.dart' are of the form.

```text
// asset_registry.dart

static const directories = [
'images',
'data/zips'
];

static const files = [
'images/photo.png',
'data/zips/installer.zip'
];

```

## Unpacking assets

DCli provides an api that allows your script to unpack its assets at run time.

```text
Asset().unpack({required String assetPath, String localPath})
```

e.g.

```text
Asset().unpack(assetPath: 'images/photo.png', localPath: join(HOME, 'images/photo.png'))
```

You can also 'directories' and ' files' constants defined in 'asset\_registry.dart' to determine exactly what assets were shipped. So to unpack all of the images you can:

```text
import 'asset_registry.dart';

void unpackImages()
{
    for (var file in files)
    {
        if (dirname(file) == 'images')
        {
            Asset().unpack(assetPath: file, localPath: join(HOME, file));
        }
    }
}
```

## 

## Automating packing of assets

If you use pub\_release to publish to pub.dev then you can create a pre-release hook to have pub\_release package your assets.



