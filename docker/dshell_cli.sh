#! /bin/bash


while getopts "b" opt; do
    case $opt in
    b) build=true ;; # Handle -b
    \?) ;; # Handle error: unknown option or missing required argument.
    esac
done

if [ '$build'=='true' ]; then
    sudo docker build -f ./dshell_cli.df -t dshell:dshell_cli .
fi

docker run  --volume $HOME:$HOME --network host   -it dshell:dshell_cli /bin/bash .