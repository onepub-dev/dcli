#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

void main() {
	/// --no-cache is used as we want the git clone to occur every time
	/// so we are always running of the latest version
	'sudo docker build --no-cache -f ./Dockerfile -t dshell:install_test ..'.run;

}
