#!/bin/bash

somme(){
    expr $(bc -l <<<"scale=2; $1 + $2")
}

difference(){
    expr $(bc -l <<<"scale=2; $1 - $2")
}

produit(){
    expr $(bc -l <<<"scale=2; $1 * $2")
}

division(){
    expr $(bc -l <<<"scale=2; $1 / $2")
}

moyenneCase(){
    # $1 ==> group cellule (Ex : 4,5,10,-4,,4,END)

    res=0
    index=1
    nbNombre=0;
    valueCase=$(echo "$1" | cut -d ',' -f $index)
    while [[ $valueCase != "END" ]]
    do
        if [[ $valueCase =~ $NBR ]]
        then
            res=$(somme $res $valueCase)
            nbNombre=$(($nbNombre + 1))
        # else
        #     echo ""
        fi
        index=$(($index + 1))
        valueCase=$(echo "$1" | cut -d ',' -f $index)
    done
    res=$(division $res $nbNombre)
    echo $res
}

sommeCase(){
    # $1 ==> group cellule (Ex : 4,5,10,-4,,4,END)

    res=0
    index=1
    valueCase=$(echo "$1" | cut -d ',' -f $index) # $(echo "$1" | cut -d $2 -f $nbColumn)
    while [[ "$valueCase" != "END" ]]
    do
        if [[ "$valueCase" =~ $NBR ]]
        then
            res=$(somme $res $valueCase)
        # else
        #     echo ""
        fi
        index=$(($index + 1))
        valueCase=$(echo "$1" | cut -d ',' -f $index)
    done
    echo $res
}

puissance(){
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

varianceCase(){
    # $1 ==> group cellule (Ex : 4,5,10,-4,,4,END)

    moyenne=$(moyenneCase $1)
    res=0
    index=1
    nbNombre=0;
    valueCase=$(echo "$1" | cut -d ',' -f $index)
    while [[ $valueCase != "END" ]]
    do
        if [[ $valueCase =~ $NBR ]]
        then
            diff=$(difference $valueCase $moyenne)
            diff=$(puissance $diff 2)
            res=$(somme $res $diff)
            nbNombre=$(($nbNombre + 1))
        # else
        #     echo ""
        fi
        index=$(($index + 1))
        valueCase=$(echo "$1" | cut -d ',' -f $index)
    done
    res=$(division $res $nbNombre)
    echo $res
}

ecartTypeCase(){
    # $1 ==> group cellule (Ex : 4,5,10,-4,,4,END)

    res=$(varianceCase $1)
    res=$(sqrt $res)
    echo $res
}

miniCase(){
    # $1 ==> group cellule (Ex : 4,5,10,-4,,4,END)
    res=0
    first=1
    index=1
    nbNombre=0;
    valueCase=$(echo "$1" | cut -d ',' -f $index)
    while [[ $valueCase != "END" ]]
    do
        if [[ $valueCase =~ $NBR ]]
        then
            if test $first = 1
            then
                res=$valueCase
                first=0;
            else
                value=$(echo "$res > $valueCase" | bc )
                if test $value = 1
                then
                    res=$valueCase
                fi
            fi

        fi
        index=$(($index + 1))
        valueCase=$(echo "$1" | cut -d ',' -f $index)
    done
    echo $res
}

maxiCase(){
    # $1 ==> group cellule (Ex : 4,5,10,-4,,4,END)
    res=0
    first=1
    index=1
    nbNombre=0;
    valueCase=$(echo "$1" | cut -d ',' -f $index)
    while [[ $valueCase != "END" ]]
    do
        if [[ $valueCase =~ $NBR ]]
        then
            if test $first = 1
            then
                res=$valueCase
                first=0;
            else
                value=$(echo "$res < $valueCase" | bc )
                if test $value = 1
                then
                    res=$valueCase
                fi
            fi

        fi
        index=$(($index + 1))
        valueCase=$(echo "$1" | cut -d ',' -f $index)
    done
    echo $res
}

medianeCase(){
    res=0
    index=1
    nbNombre=0;
    valueCase=$(echo "$1" | cut -d ',' -f $index)
    while [[ $valueCase != "END" ]]
    do
        if [[ $valueCase =~ $NBR ]]
        then
            res+="$valueCase-"
            nombre[$nbNombre]=$valueCase
            nbNombre=$(($nbNombre + 1))
        fi
        index=$(($index + 1))
        valueCase=$(echo "$1" | cut -d ',' -f $index)
    done
    elt=0
    while [[ $elt -lt $nbNombre ]]
    do
        mini=${nombre[$elt]}
        indexMini=$elt

        for (( i=$(($elt + 1)); i <= $nbNombre; i++ ));
        do
            # value=$(bc <<< "${mini} - ${nombre[$i]}")
            # if [[ $(echo "${mini} > ${nombre[$i]}" | bc) = 1 ]]
            if [[ `echo "${mini} > ${nombre[$i]}" | bc` -eq 1 ]]
            then
               mini=${nombre[$i]}
               indexMini=$i
            fi
        done
        nombre[$indexMini]=${nombre[$elt]}
        nombre[$elt]=${mini}
        elt=$(($elt + 1))
    done
    index=$(($nbNombre / 2))
    indexPlus1=$(($index + 1))
    if [[ `echo "$nbNombre % 2" | bc` -eq 0 ]]
    then 
        res=$(somme ${nombre[index]} ${nombre[indexPlus1]})
        echo $(division $res 2)
    else
        echo "${nombre[$index]}"
    fi
    # echo "${nombre[*]}"
}

ln(){
    expr $(bc -l <<<"scale=2; l($1)")

}

exp(){
    expr $(bc -l <<<"scale=2; e($1)")
}

sqrt(){
    expr $(bc -l <<<"scale=2; sqrt($1)")
}

concatChaine(){
    # $1 -> chaine1
    # $2 -> chaine2
    echo "${1:0:${#1}-1}${2:1:${#2}-1}"
}

lengthChaine(){
    res=$(echo -n $1 | wc -m)
    res=$(($res - 2))
    echo $res
}

subsituteChaine(){
    # $1 -> chaine 1 (Ex : aabbccaa)
    # $2 -> chaine 2 (Ex : aa)
    # $3 -> chaine 3 (Ex : dd)

    chaine1=$(echo `expr $2 : "\(.*\).$"`)
    chaine2=$(echo `expr $3 : "\(.*\).$"`)
    res=$(echo "$1" | sed "s/${chaine1:1}/${chaine2:1}/g")
    echo $res
}