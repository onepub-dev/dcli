# DCli Compile

The compile command will compile your DCli script\(s\) into a native executable and optionally install it into your PATH.

The resulting native application can be copied to any binary compatible OS and run without requiring Dart or DCli to be installed.

Dart complied applications are also super fast.

Usage: `dcli compile [-nc, -i, -o] [<script path.dart>, <script path.dart>,...]`

Example:

{% tabs %}
{% tab title="Linux" %}
```bash
dcli compile hello_world.dart

./hello_world
```
{% endtab %}

{% tab title="OSx" %}
```
dcli compile hello_world.dart

./hello_world
```
{% endtab %}

{% tab title="Windows" %}
```
dcli compile hello_world.dart

hello_world.exe
```
{% endtab %}
{% endtabs %}

You may specify one or more scripts and dcli will compile each of them.

If you don't specify any scripts then dcli will compile all scripts in the current directory.

If you use the --install option the compiled exe will be added to your path.

{% tabs %}
{% tab title="Linux" %}
```bash
dcli compile --install hello_world.dart

hello_world
```
{% endtab %}
{% endtabs %}

### Flags:

####  --noclean \| -nc : 

stop dcli from running clean before doing a compile. Use this option if you know that you scripts dependency haven't change since the last compile resulting in a faster compile.

####  --install \| -i : 

install the compiled script into the ~/.dcli/bin directory which is on your path. -

#### -overwrite \| -o :

 if the target script has already been compiled and installed you must specify the -o flag to allow dcli to overwrite it.

