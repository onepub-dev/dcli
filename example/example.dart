#! /usr/bin/env dshell
/*
@pubspec
name: tryme
dependencies:
  dshell: ^1.0.7
  money2: ^1.0.3
*/

import 'dart:io';

import 'package:dshell/functions/read.dart';
import 'package:dshell/dshell.dart';
import 'package:money2/money2.dart';

void main() {
  try {
    Settings().debug_on = false;

    // use external package that is included
    // by inline pubspec.yaml above.
    Currency aud = Currency.create("AUD", 2);
    Money tax = Money.fromInt(1000, aud);
    print(tax.toString());

    // Print the current working directory
    print("PWD: ${pwd}");
    echo("PWD: ${pwd}");

    String baseDir = "poetry";

    // We could use cd, push and pop but that is considered bad
    // practice.
    // So we use explict paths becuase we are good people.
    String poetryForReviews = join(baseDir, "forReview");

    // Create a directory to hold poems for review
    // creating  any needed parents.
    createDir(poetryForReviews, recursive: true);

    // Creating a directory to hold our published work.
    String poetryPublished = join(baseDir, "published");
    createDir(poetryPublished, recursive: true);

    // Create a self edifying poem.
    String poem = 'poem.txt';

    // write a poem of such beauty it will mesmerise the beholder.
    String verse1 = """
    A rose is a rose by any other name.
    But don't let its beauty bewilder you,
    as its tongue is sharp and it will surely tear you apart.
    Go not amongst the roses, for they will surely taunt your ever step
    and claw at your very flesh.""";

    String verse2 = """
    Do not listen to the gardener, they are not your friend.
    The will speak with venom of the Aphids that suck the sap
    and praise the lady beetle that attack the poor Aphid.
    But know the truth, the Aphid is your friend, and the
    beetle your mortal enemy.
    The Aphid would bring down the fearful rose but that
    garish bettle will consume with glee the poor Aphid. 
    """;

    String restingPlace = join(poetryForReviews, poem);

    // Write the verses to poem.txt
    // in the review directory.

    // write vs, truncating the file if required.
    restingPlace.write(verse1);
    restingPlace.append("");
    restingPlace.append(verse2);

    // take a moments beauty sleep to bask in our own
    // glory for a couple of seconds because we are worth it.
    sleep(2);

    echo("Find files matching *.txt");
    // Find all files that end with .jpg
    // in the current directory and any subdirectories
    for (var file in find("*.txt").toList()) {
      print(file);
    }

    // or use the forEach method which will
    // print each match as its found.
    echo("Print matches as we go");
    find("*.txt").forEach((line) => print(line));

    print("");
    print("Please review this most gloreous work.");
    print("");

    // Review our good woork.
    cat(restingPlace);

    read(restingPlace, delim: "\r\n").forEach((line) => print(line));

    // ask the user if we are ready to publish.
    // But we can't do this in a vscode debug session
    // so commenting it out for now.
    // a patch is comming for vscode.
    String publish = ask(prompt: "Publish (y/n):");

    //String publish = 'y';
    if (publish.toLowerCase() == 'y') {
      // move to the published directory.
      move(restingPlace, poetryPublished);

      restingPlace = join(poetryPublished, poem);
      // Confirm that our poem arrived safely.
      if (exists(restingPlace)) {
        print("");
        print("Our joy has been published, for all to behold.");
        print("");
      }
    } else {
      print("What my prose is not good enough; you heathen.");
    }

    // Lets get a word count
    'wc $restingPlace'
        .forEach((line) => print("WC: $line"), stderr: (line) => print(line));

    print("");

    // Find each line in our poem that contains the word rose.
    'grep rose $restingPlace'.forEach((line) => print("Grep: $line"),
        stderr: (line) => [print(line)]);

    // lets do some pipeing and see the 3-5 lines
    ('head  -5 $restingPlace' | 'tail -n 3').forEach((line) => print(line));

    // but the world doesn't deserve our work
    // so burn it all to hell.
    delete(restingPlace, ask: false);
  } catch (e) {
    // All errors are thrown as exceptions.
    print("An error occured: ${e.toString()}");
    e.printStackTrace();
  }
}
