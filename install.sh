echo Compiling
/usr/lib/dart/bin/dart2native bin/main.dart -o bin/dshell
echo Installing

# update this line to point to the root of your flutter install.
FLUTTER_HOME=~/apps
cp bin/dshell ${FLUTTER_HOME}/flutter/bin/cache/dart-sdk/bin
