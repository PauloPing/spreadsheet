#!/bin/bash
# Groupe de 2   : Louis et Paul 

./function-verification/nbParams.sh $@
test $? -eq 2 && exit 1;