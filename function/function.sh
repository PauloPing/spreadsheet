#!/bin/bash

source ./function/calc.sh 
source ./function/function_cellule.sh

NBR='(^[+-]?[0-9]*[\.])?[0-9]+$'
CELLULE='^(l[0-9]*)c[0-9]*$'
# CHAINE='^(L[0-9]*)C[0-9]*$'
CHAINE='^\"[a-zA-Z0-9]*\"'

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

      if  test "$carac" == '('
      then 
        virgule=$(($virgule + 1))
      elif test "$carac" == ')'
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
  # echo "OK"
  trouv=1
  value=$(echo "$1"| sed 's/^[a-z+-/\^]*(//; s/.$//')
  if [ "${1:0:5}" = 'shell' ]
  then
    trouv=0
    res=$($value)
    echo "$res"
  fi
  # firstPart=$(echo "$1" | sed 's/.*(//; s/,.*//');
  # secondPart=$(echo "$1" | sed 's/.*,//; s/).*//');
  
  # echo "+(*(4, 5),4)" | sed 's/^.(//; s/.$//'         *(4, 5),4
  if test $trouv == 1
  then
    firstPart=$(getPartOfParam "$value" 1)
    secondPart=$(getPartOfParam "$value" 2)

    # if [[ $firstPart =~ $CELLULE ]]
    # then
    #   firstPart=$(getCase ${firstPart:1:1} ${firstPart:3:1} $2 $3 $4)
    # fi 

    # if [[ $secondPart =~ $CELLULE ]]
    # then
    #   secondPart=$(getCase ${secondPart:1:1} ${secondPart:3:1} $2 $3 $4)
    # fi

    if [ "${1:0:1}" = '[' ]
    then
    # echo "---- ${1:0:6} ---- "
      if [[ "${1:1:4}" =~ $CELLULE && "${1:5:1}" = ']' ]]
      then
        res=$(getCase ${1:2:1} ${1:4:1} $2 $3 $4)
      else
        echo "ERROR"
      fi
    elif [ "${1:0:4}" = 'size' ]
    then
      if [[ -f $firstPart ]]
      then
        res=$(wc -c < $firstPart)
      elif [[ $firstPart =~ $CELLULE ]]
      then
        firstPart=$(getCase ${firstPart:1:1} ${firstPart:3} $2 $3 $4)
        if [[ -f $firstPart ]]
        then
          res=$(wc -c < "$firstPart")
        else
          res=0;
        fi
      else
        res=0;
      fi
    elif [ "${1:0:4}" = 'line' ]
    then 
      if [[ -f $firstPart ]]
      then
        res=$(wc -l < $firstPart)
        res=$(($res + 1))
      elif [[ $firstPart =~ $CELLULE ]]
      then
        firstPart=$(getCase ${firstPart:1:1} ${firstPart:3:1} $2 $3 $4)
        res=$(wc -l < $firstPart)
        res=$(($res + 1))
      else 
        res=0
      fi
    elif [ "${1:0:9}" = 'subsitute' ]
    then 
      thirdPart=$(getPartOfParam $value 3)
      if ! [[ $firstPart =~ $CHAINE ]]
      then
        firstPart=$(calcule $firstPart $2 $3 $4);
      elif ! [[ $secondPart =~ $CHAINE ]]
      then
        secondPart=$(calcule $secondPart $2 $3 $4);
      elif ! [[ $thirdPart =~ $CHAINE ]]
      then
        thirdPart=$(calcule $thirdPart $2 $3 $4);
      fi
      res=$(subsituteChaine $firstPart $secondPart $thirdPart);
    elif [ "${1:0:6}" = 'length' ]
    then  
      if [[ $value =~ $CHAINE ]]
      then
        res=$(lengthChaine $value);
      else
        val=$(calcule $value $2 $3 $4);
        res=$(lengthChaine $val);
      fi
    elif [ "${1:0:6}" = 'concat' ]
    then
      if  ! [[ $firstPart =~ $CHAINE ]]
      then
        firstPart=$(calcule $firstPart $2 $3 $4);
      fi
      if ! [[ $secondPart =~ $CHAINE ]]
      then
        secondPart=$(calcule $secondPart $2 $3 $4);
      fi
      res=$(concatChaine $firstPart $secondPart);
    elif [[ $firstPart =~ $CELLULE && $secondPart =~ $CELLULE ]]
    then
      
      res=$(getValueCellule $firstPart $secondPart $2 $3 $4);
      if [ "${1:0:5}" = 'somme' ]
      then
        res=$(sommeCase $res);
      elif [ "${1:0:7}" = 'moyenne' ]
      then
        res=$(moyenneCase $res);
      elif [ "${1:0:8}" = 'variance' ]
      then
        res=$(varianceCase $res);
      elif [ "${1:0:9}" = 'ecarttype' ]
      then
        res=$(ecartTypeCase $res);
      elif [ "${1:0:7}" = 'mediane' ]
      then
        res=$(medianeCase $res);
      elif [ "${1:0:4}" = 'mini' ]
      then
        res=$(miniCase $res);
      elif [ "${1:0:4}" = 'maxi' ]
      then
        res=$(maxiCase $res);
      fi
    
    else

      if [[ $firstPart =~ $CELLULE ]]
      then
        firstPart=$(getCase ${firstPart:1:1} ${firstPart:3:1} $2 $3 $4)
      
      elif ! [[ "$firstPart" =~ $NBR ]]
      then
        # echo "$firstPart"
        firstPart=$(calcule "$firstPart" $2 $3 $4)
      fi

      if [[ $secondPart =~ $CELLULE ]]
      then
        secondPart=$(getCase ${secondPart:1:1} ${secondPart:3:1} $2 $3 $4)
      elif ! [[ "$secondPart" =~ $NBR || $secondPart == "" ]]
      then
        secondPart=$(calcule "$secondPart" $2 $3 $4)
      fi

      # if ! [[ $secondPart =~ $NBR || $secondPart == "" ]]
      # then
      #   firstPart=$(calcule $secondPart $2 $3 $4)
      # fi

      if [ "${firstPart:0:1}" = '.' ]
      then 
        firstPart="0${firstPart}"
      fi

      if [ "${secondPart:0:1}" = '.' ]
      then 
        secondPart="0${secondPart}"
      fi


      if [ "${1:0:1}" = '+' ]
      then
        res=$(somme $firstPart $secondPart);
        # echo "$firstPart === $secondPart"

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
  fi

}

rowToResultFile(){
  # $1 -> Row
  # $2 -> separator column in $feuille
  # $3 -> separator column in $result
  # $4 -> result File 
  # $5 -> separator lign in $result

  nbColumn=1
  ROW=""
  column=$(echo "${1}$2" | cut -d "$2" -f $nbColumn)
  while [ -n "$column" ]
  do
    if test $nbColumn != 1
    then 
      ROW+="$3"
    fi
    if [ ${column:0:1} = '=' ]
    then
      res=$(calcule "${column:1}" $4 $3 $5)
      column=$res;
    fi
    ROW+="${column}"
    nbColumn=$(($nbColumn + 1));
    column=$(echo "${1}$2" | cut -d "$2" -f $nbColumn)
  done
  echo $ROW;
}