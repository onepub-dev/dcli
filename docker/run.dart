#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

void main() {
	'sudo docker build -f ./Dockerfile -t dshell:install_test ..'.run;

}
