# Install DCli

To get started with DCli you first need to install Dart and optionally the DCli tools.

{% hint style="info" %}
If you just want to use the DCli library then you don't need to install the [DCli tools](dcli-tools-1/dcli-tools.md).
{% endhint %}

There are three methods for installing Dart and the DCli tools.

## Use DCli library from your project Option 1

If you only want to use the DCli library then you can add DCli to your pubspec.yaml as you would any other package.

```yaml
dependencies:
  dcli: 0.37.0
```

Check pub.dev for the latest version no.

[https://pub.dev/packages/dcli/install](https://pub.dev/packages/dcli/install)

## Install Dart/DCli Option 2

Start by installing Dart as per:

{% hint style="info" %}
Install Dart from : [https://dart.dev/get-dart](https://dart.dev/get-dart)
{% endhint %}

If you want to use the [DCli tools](dcli-tools-1/dcli-tools.md), including Shebang \(\#!\) support you need to globally activate DCli.

If you only want to use the DCli API then you can skip this step.

Now activate the DCli tools:

```text
pub global activate dcli
dcli install
```

## Install Dart/DCli Option 3

This is still a work in progress but is intended to provide a three line script to install Dart and the DCli tools.

{% tabs %}
{% tab title="Linux" %}
```text
wget https://github.com/bsutton/dcli/releases/download/latest-linux/dcli_install
chmod +x dcli_install
./dcli_install
```
{% endtab %}

{% tab title="Windows" %}
```text
curl https://github.com/bsutton/dcli/releases/download/latest-windows/dcli_install.exe
dcli_install.exe
```
{% endtab %}

{% tab title="OSX" %}
```text
Coming soon:

curl https://github.com/bsutton/dcli/releases/download/latest-osx/dcli_install
dcli_install.exe
```
{% endtab %}
{% endtabs %}

## Install VSCode

You can use virtually any editor to create DCli scripts but we use and recommend Visual Studio Code \(vscode\) with the Dart-Code plugin.

{% hint style="info" %}
Install Visual Studio Code from: [https://code.visualstudio.com/download](https://code.visualstudio.com/download)
{% endhint %}

Now install the vscode extension for Dart - Dart Code:

{% hint style="info" %}
Install Dart-Code from: [dartcode.org](https://dartcode.org/#:~:text=You%20must%20have%20the%20VS,and%20debugger%20for%20VS%20Code.)
{% endhint %}

We use and recommend the following additional vscode extensions:

* Dart-Code.flutter
* dart-import
* pubspec-assist
* vscode-browser-preview
* bracket-pair-colorizer
* LogFileHighlighter

