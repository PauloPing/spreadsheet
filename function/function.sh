#!/bin/bash
#include <math.h>

produit ()
{
    res=`$1 * $2`
    return res
}

quotient ()
{
    res=`expr $1\/$2`
    return res
}

puissance ()
{
    res=$1
    while test $2 -ne 0 
    do
        res=`expr $res * $1`
    done
    return res
}

ln ()
{
    a=$1
    res=$(bc -l <<<"l($a)")
    return res
}

exp ()
{
    a=$1
    res=$(bc -l <<<"e(25)")
    return res
}

sqrt ()
{
    a=$1
    res=$(bc -l <<<"sqrt($a)")
    return res
}

