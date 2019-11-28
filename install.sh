echo Compiling
/usr/lib/dart/bin/dart2native bin/main.dart -o bin/dshell
echo Installing

cp bin/dshell  /usr/bin
