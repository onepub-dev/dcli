# Install DCli

To get started with DCli you first need to install Dart and optionally the DCli tools.

{% hint style="info" %}
If you just want to use the DCli library then you don't need to install the [DCli tools](../dcli-tools-1/dcli-tools.md).
{% endhint %}

There are three methods for installing Dart and the DCli tools.

## Option 1) Use DCli library from your project

If you only want to use the DCli library then you can add DCli to your pubspec.yaml as you would any other package.

```yaml
cd /my/dart/project
dart pub add dcli
```

## Option 2) Install Dart/DCli

Start by installing Dart as per:

{% hint style="info" %}
Install Dart from: [https://dart.dev/get-dart](https://dart.dev/get-dart)
{% endhint %}

If you want to use the [DCli tools](../dcli-tools-1/dcli-tools.md), including Shebang (#!) support you need to globally activate DCli.

Now activate the DCli tools:

```
dart pub global activate dcli
dcli install
```

## Option 3) Install Dart/DCli

This is still a work in progress but is intended to provide a three-line script to install Dart and the DCli tools.

{% tabs %}
{% tab title="Linux" %}
```
wget https://github.com/onepub-dev/dcli/releases/download/latest.linux/dcli_install
chmod +x dcli_install
sudo ./dcli_install
```
{% endtab %}

{% tab title="Windows" %}
```
curl https://github.com/onepub-dev/dcli/releases/download/latest.windows/dcli_install.exe
dcli_install.exe
```
{% endtab %}

{% tab title="OSX" %}
```
Coming soon:

curl https://github.com/onepub-dev/dcli/releases/download/latest.osx/dcli_install
dcli_install.exe
```
{% endtab %}
{% endtabs %}

## Install VSCode

You can use virtually any editor to create DCli scripts but we use and recommend Visual Studio Code (vscode) with the Dart-Code plugin.

{% hint style="info" %}
Install Visual Studio Code from: [https://code.visualstudio.com/download](https://code.visualstudio.com/download)
{% endhint %}

Now install the vs code extension for Dart - Dart Code:

{% hint style="info" %}
Install Dart-Code from: [dartcode.org](https://dartcode.org)
{% endhint %}

We use and recommend the following additional vscode extensions:

* Dart-Code.flutter
* dart-import
* pubspec-assist
* vscode-browser-preview
* bracket-pair-colorizer
* LogFileHighlighter
