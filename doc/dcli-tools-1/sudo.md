# Sudo

You will often want to run a DCli script using sudo.

Using sudo can complicate things as on debian sudo has its own path which is unlikely to include the dart or dcli paths.

There are two ways to over come this problem:

1\) pass your path down to sudo

```text
sudo env "PATH=$PATH" <my dcli script>
```

2\) compile you script.

A dart script needs to be able to find both dcli and dart on your path. If you compile your script then you end up with a fully self contained exe. 

```text
dcli compile <my dcli script.dart>
sudo <my dcli script>
```

