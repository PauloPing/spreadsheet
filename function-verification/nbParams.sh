#!/bin/bash

test $# -gt 7 && echo "Number of params is not correct!" && exit 2;
test $# -gt 0 && [ $1 != -in ] && [ ! -f $1 ] && echo "Write \"-in\" to get the result on the standard input or the name of a file!"
test $# -gt 1 && [ $2 != -out ] && [ ! -f $2 ] && echo "Write \"out\" to get the result on the standard output or the name of a file!"
test $# -gt 2 && [ $3 != -scin ] && [[ ${#3} -gt 1 ]] && echo "Params -scin is not correct!"
test $# -gt 3 && [ $4 != -slin ] && [[ ${#4} -gt 1 ]] && echo "Params -slin is not correct!"
test $# -gt 4 && [ $5 != -scout ] && [[ ${#5} -gt 1 ]] && echo "Params -scout is not correct!"
test $# -gt 5 && [ $6 != -slout ] && [[ ${#6} -gt 1 ]] && echo "Params -slout is not correct!"
test $# -gt 6 && [ $7 != -inverse ] && echo "Write \"-inverse\" reverse row and column, else whrite nothing"

