#!/bin/bash

NBR='^[0-9]+'
getCase(){
  #  ($1, $2) -> coordinate case
  #  $3 -> file
  #  $4 -> -scin sep
  #  $5 -> -slin sep  

  if test "$5" = '\n'
  then
    sed  $1'!d' $3 | cut -d $4 -f $2
  else
    cut -d $5 -f $1 $3 | cut -d $4 -f $2
  fi
}

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

  if test $trouv == 0
  then
    res=$(echo "$param" | sed 's/^=\([a-z]*\)(//; s/.$//')
    # CORRIGER ECHO FONCTIONNE PAS POUR LE LN
  fi
}

calcule(){
  
  # $1 -> column without '=' (Ex : =+(2,3) ==> +(2,3))
  
  value=$(echo "$1"| sed 's/^.(//; s/.$//')
  firstPart=$(getPartOfParam $value 1)
  secondPart=$(getPartOfParam $value 2)
  # firstPart=$(echo "$1" | sed 's/.*(//; s/,.*//');
  # secondPart=$(echo "$1" | sed 's/.*,//; s/).*//');
  
  # echo "+(*(4, 5),4)" | sed 's/^.(//; s/.$//'         *(4, 5),4

  if ! [[ $firstPart =~ $NBR ]]
  then
    firstPart=$(calcule $firstPart)
  fi

  if ! [[ $secondPart =~ $NBR || $secondPart == "" ]]
  then
    secondPart=$(calcule $secondPart)
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
  fi
  echo $res

}

rowToResultFile(){
  # $1 -> Row
  # $2 -> separator column in $feuille
  # $3 -> separator column in $result
  # $4 -> result File 

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
      res=$(calcule ${column:1})
      column=$res;
    fi
    ROW+="${column}"
    nbColumn=$(($nbColumn + 1));
    column=$(echo $1 | cut -d $2 -f $nbColumn)
  done
  echo $ROW;
}