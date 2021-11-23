#!/bin/bash

somme()
{
    # expr $1 + $2
    expr $(bc -l <<<"scale=2; $1 + $2")
}

difference()
{
    # expr $1 - $2
    expr $(bc -l <<<"scale=2; $1 - $2")
}

produit()
{
    # expr $1 \* $2
    expr $(bc -l <<<"scale=2; $1 * $2")
}

division()
{
    # expr $1 / $2
    expr $(bc -l <<<"scale=2; $1 / $2")
}

sommeCase(){
    # $1 ==> group cellule (Ex : 4,5,10,-4,,4,END)

    res=0
    index=1
    valueCase=$(echo "$1" | cut -d ',' -f $index) # $(echo "$1" | cut -d $2 -f $nbColumn)
    while [[ $valueCase != "END" ]]
    do
        if [[ $valueCase =~ $NBR ]]
        then
            res=$(somme $res $valueCase)
        else
            echo ""
        fi
        index=$(($index + 1))
        valueCase=$(echo "$1" | cut -d ',' -f $index)
    done
    echo $res
}

puissance()
{
    val=$1
    res=$1
    index=1
    while test $index -ne $2
    do 
        val=$(produit $val $res)
        index=$(($index+1))
    done
    expr $val
}

ln()
{
    # echo "scale=2; l($1)" | bc -l 
    expr $(bc -l <<<"scale=2; l($1)")

}

exp()
{
    expr $(bc -l <<<"scale=2; e($1)")
}

sqrt()
{
    expr $(bc -l <<<"scale=2; sqrt($1)")
}

# echo somme 2 1
# echo difference 5 1
# echo produit 5 2
# echo division 8 2
# echo puissance 5 2
# echo ln 2
# echo exp 2
# echo sqrt 25