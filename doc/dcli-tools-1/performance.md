# Performance

## Performance

DCli is intended to start as fast as Bash and run faster than Bash.

When you first run your new DCli script, DCli has some house keeping to do including running a `pub get` which retrieves and caches any of your scripts dependencies.

The result is that DCli has similar start times to Bash and when running larger scripts is faster than Bash.

If you absolutely need to make your script perform to the max, you will want to use DCli to compile your script.

### Compiling to Native

DCli also allows you to compile your script and any dependencies to a native executable.

```text
dcli compile <scriptname.dart>
```

DCli will automatically mark your new exec as executable using `chmod +x`.

Run you natively compiled script to see just how much faster it is now:

{% tabs %}
{% tab title="Linux" %}
```text
./scriptname
```
{% endtab %}

{% tab title="OSX" %}
```
./scriptname
```
{% endtab %}

{% tab title="Windows" %}
```
scriptname.exe
```
{% endtab %}
{% endtabs %}

As this the script fully compiled, changes to your local script file will NOT affect it \(until you recompile\) and when the exe runs it will never need to do a pub get as all dependencies are compiled into the native executable.

Check out the the --install option to install the script into your path.

You can now copy the exe to another machine \(that is binary compatible\) and run the exe without having to install Dart, DCli or any other dependency.

{% hint style="info" %}
Once compiled your script will run on any binary compatible machine WITHOUT dart or dcli.
{% endhint %}

