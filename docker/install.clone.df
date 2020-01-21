FROM google/dart

WORKDIR /


#RUN ssh -Tv git@github.com 


#RUN git clone git@github.com:bsutton/dshell.git

RUN git clone https://github.com/bsutton/dshell.git

RUN find / -name pubspec.yaml


RUN pub global activate --source path /dshell 


CMD []

ENTRYPOINT ["/usr/bin/dart", "/dshell/test_install/install_test.dart"] 
