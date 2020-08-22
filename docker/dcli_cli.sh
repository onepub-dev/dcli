#! /bin/bash


while getopts "b" opt; do
    case $opt in
    b) build=true ;; # Handle -b
    \?) ;; # Handle error: unknown option or missing required argument.
    esac
done

if [ '$build'=='true' ]; then
    sudo docker build -f ./dcli_cli.df -t dcli:dcli_cli .
fi

docker run  --volume $HOME:$HOME --network host   -it dcli:dcli_cli /bin/bash .