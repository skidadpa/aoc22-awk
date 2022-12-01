#!/bin/bash
cd $(dirname $0)
for d in day*
do
    echo + $d
    make -C $d
done
