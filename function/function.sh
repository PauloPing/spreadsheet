#!/bin/bash

source ./function/calc.sh 
source ./function/function_cellule.sh

NBR='(^[+-]?[0-9]*[\.])?[0-9]+$'
CELLULE='^(L[0-9]*)C[0-9]*$'

getPartOfParam(){
  # $1 => ligne
  # $2 -> Param 1 or 2 
  param=""
  compteur=0
  virgule=0

  carac=${1:$compteur:1}
  trouv=0

  while test "$carac" != ''
  do
    if [[ $carac == ',' && $virgule == 0 ]]
    then 
      if [[ $2 == 1 ]]
      then 
        trouv=1
        echo $param
      else
        param=""
        while test "$carac" != ''
        do
          compteur=$(($compteur + 1))
          carac=${1:$compteur:1}
          param+="$carac"
        done
        trouv=1
        echo $param
      fi
    else
      param+="$carac"

      if  test $carac == '('
      then 
        virgule=$(($virgule + 1))
      elif test $carac == ')'
      then
        virgule=$(($virgule - 1))
      fi
    fi
    compteur=$(($compteur + 1))
    carac=${1:$compteur:1}
  done

  param+=")"
  if test $trouv == 0
  then
    res=$(echo "$param" | sed 's/^\([a-z]*\)(//; s/.$//')
    echo $res
  fi
}


calcule(){
  
  # $1 -> column without '=' (Ex : =+(2,3) ==> +(2,3))
  # $2 -> file result 
  # $3 -> -scout 
  # $4 -> -slout 
  
  value=$(echo "$1"| sed 's/^[a-z+-/\^]*(//; s/.$//')
  firstPart=$(getPartOfParam $value 1)
  secondPart=$(getPartOfParam $value 2)
  # firstPart=$(echo "$1" | sed 's/.*(//; s/,.*//');
  # secondPart=$(echo "$1" | sed 's/.*,//; s/).*//');
  
  # echo "+(*(4, 5),4)" | sed 's/^.(//; s/.$//'         *(4, 5),4


  if [[ $firstPart =~ $CELLULE && $secondPart =~ $CELLULE ]]
  then
    res=$(getValueCellule $firstPart $secondPart $2 $3 $4);
    if [ "${1:0:5}" = 'somme' ]
    then
      res=$(sommeCase $res);
    fi
  else

    if ! [[ $firstPart =~ $NBR ]]
    then
      firstPart=$(calcule $firstPart $2 $3 $4)
    fi

    if ! [[ $secondPart =~ $NBR || $secondPart == "" ]]
    then
      secondPart=$(calcule $secondPart $2 $3 $4)
    fi

    if [ ${firstPart:0:1} = '.' ]
    then 
      firstPart="0${firstPart}"
    fi

    if [ ${secondPart:0:1} = '.' ]
    then 
      secondPart="0${secondPart}"
    fi

    if [ "${1:0:1}" = '+' ]
    then
      res=$(somme $firstPart $secondPart);

    elif [ "${1:0:1}" = '-' ]
    then 
      res=$(difference $firstPart $secondPart);

    elif [ "${1:0:1}" = '*' ]
    then 
      res=$(produit $firstPart $secondPart);

    elif [ "${1:0:1}" = '/' ]
    then 
      res=$(division $firstPart $secondPart);

    elif [ "${1:0:1}" = '^' ]
    then 
      res=$(puissance $firstPart $secondPart);

    elif [ "${1:0:2}" = 'ln' ]
    then 
      res=$(ln $firstPart);
    
    elif [ "${1:0:1}" = 'e' ]
    then 
      res=$(exp $firstPart);
    
    elif [ "${1:0:4}" = 'sqrt' ]
    then 
      res=$(sqrt $firstPart);
    
    elif [ "${1:0:1}" = '^' ]
    then 
      res=$(puissance $firstPart $secondPart);

    fi
  fi
  echo $res

}

rowToResultFile(){
  # $1 -> Row
  # $2 -> separator column in $feuille
  # $3 -> separator column in $result
  # $4 -> result File 
  # $5 -> separator lign in $result

  nbColumn=1
  ROW=""
  column=$(echo "$1" | cut -d $2 -f $nbColumn)
  while [ -n "$column" ]
  do
    if test $nbColumn != 1
    then 
      ROW+="$3"
    fi
    if [ ${column:0:1} = '=' ]
    then 
      res=$(calcule ${column:1} $4 $3 $5)
      column=$res;
    fi
    ROW+="${column}"
    nbColumn=$(($nbColumn + 1));
    column=$(echo $1 | cut -d $2 -f $nbColumn)
  done
  echo $ROW;
}