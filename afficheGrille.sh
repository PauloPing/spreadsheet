#!/bin/bash

index1=0
index2=0

while test $index1 -ne $1
do
    while test $index2 -ne $2
    do
        echo -n $30
        index2=`expr $index2 + 1`
    done
    echo $3
    index1=`expr $index1 + 1`
    index2=0
done
