# Templates

Templates are a work in progress.

DCli ships a number of templates which are intended to be used with the dcli create command.

Currently the dcli create uses one fixed template.

Going forward the intent is to add a --template switch to the create command so the user can choose which template to use.

## Creating templates

Each template must live in its own dart project as a subproject in github. &#x20;

A template should consist of a complete dart project including an analysis\_options.yaml file that conforms to the DCli lint standards (copy dcli's existing file).

