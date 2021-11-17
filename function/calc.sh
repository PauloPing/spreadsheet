#!/bin/bash

somme()
{
    expr $1 + $2
}

difference()
{
    expr $1 - $2
}

produit()
{
    expr $1 * $2
}

division()
{
    expr $1 / $2
}

puissance()
{
    val=$1
    res=$1
    index=1
    while test $index -ne $2
    do 
        val=$(($val*$res))
        index=$(($index+1))
    done
    expr $val
}

ln()
{
    expr $(bc -l <<<"l($1)")
}

exp()
{
    expr $(bc -l <<<"e($1)")
}

sqrt()
{
    expr $(bc -l <<<"sqrt($1)")
}

# echo somme 2 1
# echo difference 5 1
# echo produit 5 2
# echo division 8 2
# echo puissance 5 2
# echo ln 2
# echo exp 2
# echo sqrt 25