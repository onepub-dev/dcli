# Getting Started

To get started with DCli you first need to install Dart and optionally DCli.

There are two methods for installing Dart and DCli.

## Install Dart/DCli Option 1

Start by installing Dart as per:

{% hint style="info" %}
Install Dart from : [https://dart.dev/get-dart](https://dart.dev/get-dart)
{% endhint %}

If you want to use DCli's optional command line tools including Shebang \(\#!\) support you need to globally activate DCli.

If you only want to use the DCli API then you can skip this step.

Now activate DCli:

```text
pub global activate dcli
dcli install
```

## Install Dart/DCli Option 2

This is still a work in progress but is intended to provide a three line script to install Dart and DCli.

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

