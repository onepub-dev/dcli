#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

void main() {
  // find all java processes
  bool killed = false;
  'ps aux'.forEach((line) {
    if (line.contains("java") && line.contains("tomcat")) {
      List<String> parts = line.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        String pidPart = parts[1];
        int pid = int.tryParse(pidPart) ?? -1;
        if (pid != -1) {
          print('Killing tomcat with pid=$pid');
          'kill -9 $pid'.run;
          killed = true;
        }
      }
    }
  });

  if (killed == false) {
    print("tomcat process not found.");
  }
}
