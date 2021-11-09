#!/bin/bash

test $# -gt 7 && echo "Number of params is not correct" && exit 2;
test $# -gt 0 && [ $1 != -in ] && [ ! -f $1 ] && echo "Write \"-in\" to get the result on the standard input or the name of a file"
test $# -gt 1 && [ $2 != -out ] && [ ! -f $1 ] && echo "Write \"out\" to get the result on the standard output or the name of a file"
test $# -gt 2 && [ $3 != -scin ]

