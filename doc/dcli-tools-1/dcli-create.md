# DCli Create

The `dcli create` command makes it easier to create new scripts and templates.

The `dcli create` command can create a project or add a script  to an existing Dart project.

When creating a script the Dart project must already exist.

When creating a project `dcli create` performs the following actions:

* creates the project directory
* creates \<bin/\<script>.dart>
* creates pubspec.yaml
* creates analysis\_options.yaml
* marks your script as executable
* adds a shebang #! to the start of your script.
* runs `dcli warmup` in the background.

{% hint style="info" %}
dcli create won't create the pubspec.yaml nor analysis\_options.yaml if you create your new script in an existing dart project.
{% endhint %}

### Create a new project

To create a new project from scratch

Usage: `dcli create <project name>`

Example:

```
dcli create snake
Creating project snake using template console-simple.
DCli warmup started in the background.

Created project snake. 

To run your script:
  cd snake
  bin/snake.dart
```

### Add a script&#x20;

To add a script to an existing Dart project.

{% hint style="info" %}
It is common practice to have multiple scripts in your bin and tool directories.&#x20;
{% endhint %}

We recommend that you create scripts in the projects bin directory to compile wit Dart standards.

{% hint style="info" %}
You can actually place a script in any directory and it will work but it's better to stick with the Dart standards for project layout.
{% endhint %}

You may also want to create scripts in your `tool`  directory.

{% hint style="info" %}
Scripts in your tool directory should be reserved for tooling to help maintain the project and are not part of your set of public scripts.
{% endhint %}

Usage: `dcli create <script.dart>`

Example:

```
cd snake/bin
dcli create my_script.dart
Creating script my_script.dart using template .
DCli prepare started in the background.

Created script my_script.dart in snake/bin.
To run your script:
  ./my_script.dart
```

{% hint style="info" %}
vscode users: edit the project by typing 'code .' on the command line.
{% endhint %}

As the sample script has a Shebang #! added you can execute it directly:

```
./my_script.dart
```

{% hint style="info" %}
If you run you script immediately after creating it, the background 'warmup' may still be running.
{% endhint %}

In which case you may see the message:

```
./test.dart
Waiting for warmup to complete...
Hello World
```

The warmup process is a once off process and only needs to be run again if you change your dependencies.

The first time you run a given DCli script (created with dcli create), DCli needs to resolve any dependencies by running a Dart `pub get` command and doing some other housekeeping.

If you run the same script a second time DCli has already resolved the dependencies and so it can run the script immediately.

## Templates

#### Project Templates

DCli creates projects from a set of templates located in `$HOME/.dcli/template/project`

When you create a project you can specify a template:

```bash
dcli create --template=simple snake 
```

If you don't specify a template name then DCli will use `simple` by default.

DCli supports the following templates:

* simple - simple dart project with a single script in bin
* full - include a lib, test and script in bin
* cmd\_args - example parsing command line args
* find - example using the find function.

You can create custom project templates by copying a dart package into `$HOME/.dcli/template/project/custom`

Each template should be in its own directory under `custom`.

If a custom template has the same name as a standard DCli template then the custom template is used. This allows you to override the standard templates that DCli ships with.

The directory name is used as the template name in the `--template` switch.

When DCli creates a project from a template it:

* creates a directory with the provided project name (e.g. snake)
* copies all files from the given template into the new project directory
* updates the name in the pubspec.yaml file to be the project name passed to `dcli create`
* If the template's `bin` directory contains a `main.dart` then that script is renamed to \<project name>.dart
* If the template's bin directory doesn't contain a `main.dart` then the first .dart script it finds will be renamed \<project name>.dart.

#### Script Templates

DCli creates scripts from a set of templates located in `$HOME/.dcli/template/script`

When you create a script you can specify a template:

```bash
dcli create --template=simple snake.dart 
```

If you don't specify a template name then DCli will use `simple` by default.

When DCli creates a script from a template it will:

* looking in the template directory for a script called `main.dart` and copy it into the current directory.
* rename main.dart to the script name you passed to the `dcli create` command.
* If the template project doesn't contain a main.dart it will copy the first .dart script it finds and applies the same process.

### Flags

The dcli create command accepts the following flags:

\-- foreground :

If the foreground flag is passed the dcli warmup process will be ran in the foreground rather than the use background execution.

Now lets create and run our first DCli script.
