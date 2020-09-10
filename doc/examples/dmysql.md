# dmysql

The dmysql.dart script is intended to be a time save if you connect to a mysql cli on a regular basis.

dmysql allows you to save the connection details and then each time you want to connect you just need to pass in the database name:

## To see the command line options:

```text
dart dmysql.dart 
You must provide the database name
Connects you to a mysql cli pulling settings (username/password...) from a local settings file.

To connect to a db:
   dmysql <dbname>

To connfigure settings for a db:
  dmysql --config <dbname>
  
-c, --[no-]config    starts dmysql in configuration mode so you can enter the settings for the given db

```

## To configure your database:

```bash
dart dmysql.dart --config mydb
host: [] 127.0.0.1
port: [3306] 
user: [] root
password: [] <root password>
```

## To connect to your db:

```text
dart dmysql.dart mydb
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 29
Server version: 10.3.22-MariaDB-1ubuntu1 Ubuntu 20.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [mydb]> 
```

## dmysql.dart

```text
#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:args/args.dart';
import 'package:settings_yaml/settings_yaml.dart';

/// Connects you to a mysql cli pulling settings (username/password)
/// from a local settings file.
/// Use

var pathToDMysql = '$HOME/.dmysql';

void main(List<String> args) {
  var parser = ArgParser();
  parser.addFlag('config',
      abbr: 'c',
      defaultsTo: false,
      help:
          'starts dmysql in configuration mode so you can enter the settings for the given db');

  var results = parser.parse(args);
  var rest = results.rest;

  if (rest.length != 1) {
    printerr(red('You must provide the database name'));
    showUsage(parser);
  }

  var dbname = rest[0];
  var pathToDbSettings = join(pathToDMysql, dbname);

  if (results['config'] as bool) {
    config(dbname, pathToDbSettings);
  } else {
    if (!exists(pathToDbSettings)) {
      printerr(red('You must first configure your database using --config'));
      showUsage(parser);
    }
    launch(pathToDbSettings);
  }
}

void launch(String pathToDbSettings) {
  var settings = SettingsYaml.load(pathToSettings: pathToDbSettings);
  var host = settings['host'] as String;
  var port = settings['port'] as int;
  var user = settings['user'] as String;
  var password = settings['password'] as String;
  var dbname = settings['dbname'] as String;

  'mysql -h $host --port=$port -u $user --password="$password" $dbname'.run;
}

void config(String dbname, String pathToDbSettings) {
  if (!exists(dirname(pathToDbSettings))) {
    createDir(dirname(pathToDbSettings), recursive: true);
  }
  var settings = SettingsYaml.load(pathToSettings: pathToDbSettings);

  settings['dbname'] = dbname;
  settings['host'] = ask(
    'host:',
    defaultValue: settings['host'] as String,
     validator: Ask.any([
       Ask.fqdn,
       Ask.ipAddress(),
       Ask.inList(['localhost'])
    ]));
  );

  settings['port'] = int.parse(ask('port:',
      defaultValue: (settings['port'] as int ?? 3306).toString(),
      validator: Ask.integer));

  settings['user'] = ask('user:',
      defaultValue: settings['user'] as String, validator: Ask.required);

  settings['password'] = ask('password:',
      defaultValue: settings['password'] as String,
      validator: Ask.required,
      hidden: true);

  settings.save();
}

void showUsage(ArgParser parser) {
  print('''
Connects you to a mysql cli pulling settings (username/password...) from a local settings file.

${green('To connect to a db:')}
   dmysql <dbname>

${green('To connfigure settings for a db:')}
  dmysql --config <dbname>
  ''');
  print(parser.usage);
  exit(1);
}

```

## pubspec.yaml

```text
name: dmysql
version: 1.0.0
description: Saves db connection settings and connects to a db cli
environment: 
  sdk: '>=2.6.0 <3.0.0'
dependencies: 
  args: ^1.0.0
  dcli: ^0.24.1
  path: ^1.0.0
  settings_yaml: ^2.0.0

dev_dependencies: 
  pedantic: ^1.0.0

```

