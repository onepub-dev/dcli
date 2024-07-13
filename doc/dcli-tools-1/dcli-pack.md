# DCli Pack

The dcli pack command allows you to pack resources (images, config files etc) into your cli app.

Whilst flutter allows you to include assets in a dart executable no such feature exists for dart cli apps. The dcli pack command is designed to fill that void.

A resource is just a file that you want to ship with your package.

To pack a resource in you cli app create a 'resource' directory in the root of your project package.

Place each file in the resource directory.

Run `dcli pack`.

You can also pack resources external to your project by creating a tool/dcli/pack.yaml.

For further details on packing and unpacking resources see the [Asset/Resource](../dcli-api/assets.md) section.
