#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

void main() {
  try {
    Settings().debug_on = false;

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
    makeDir(poetryForReviews, createParent: true);

    // Creating a directory to hold our published work.
    String poetryPublished = join(baseDir, "published");
    makeDir(poetryPublished, createParent: true);

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
    and praise the lady beattle that attack the poor Aphid.
    But know the truth, the Aphid is your friend, and the
    beattle your mortal enemy.
    The Aphid would bring down the fearful rose but that
    garish beattle will consume with glee the poor Aphid.
    """;

    String restingPlace = join(poetryForReviews, poem);

    // open a file for writing (the default)
    // and save our poem in the review directory.
    FileSync syncFile = FileSync(restingPlace);

    syncFile.append(verse1);
    // a blank line between the verses.
    syncFile.append("");
    syncFile.append(verse2);
    syncFile.close();

    // take a moments beauty sleep to bask in our own
    // glory for a couple of seconds because we are worth it.
    sleep(2);

    echo("Find file matching *.txt");
    // Find all files that end with .jpg
    // in the current directory and any subdirectories
    for (var file in find("*.txt")) {
      print(file);
    }

    print("");
    print("Please review this most gloreous work.");
    print("");

    // Review our good woork.
    cat(restingPlace);

    // ask the user if we are ready to publish.
    // But we can't do this in a vscode debug session
    // so commenting it out for now.
    // a patch is comming for vscode.
    // String publish = ask(prompt: "Publish (y/n)");

    String publish = 'y';
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
    'wc $restingPlace'.forEach((line) => print("WC: $line"));

    print("");

    // Find each line in our poem that contains the word rose.
    'grep rose $restingPlace'.forEach((line) => print("Grep: $line"));

    // lets do some pipeing and see the 3-5 lines
    ('head  -5 $restingPlace' | 'tail -n 3').forEach((line) => print(line));

    // but the world doesn't deserve our work
    // so burn it all to hell.
    delete(join(poetryPublished, poem), ask: false);
  } catch (e) {
    // All errors are thrown as exceptions.
    print("An error occured: ${e.toString()}");
    e.printStackTrace();
  }
}
