#!/bin/bash

source ./function/calc.sh 
source ./function/function_cellule.sh

NBR='(^[+-]?[0-9]*[\.])?[0-9]+$'
CELLULE='^(l[0-9]*)c[0-9]*$'
# CHAINE='^(L[0-9]*)C[0-9]*$'
CHAINE='^\"[a-zA-Z0-9]*\"'

getPartOfParam(){
  # $1 => ligne
  # $2 -> Param 1 or 2 or 3
  compteur=0
  carac=${1:$compteur:1}
  virgule=$(($2 - 1))
  nbCalcule=0
  param=""
  trouv=0
  while [[ "$carac" != '' && $trouv -eq 0 ]] 
  do
    if  [[ "$carac" == '(' ]]
    then 
      nbCalcule=$(($nbCalcule + 1))
    # elif [[ $carac == ',' && $nbCalcule -eq 0 ]]
    # then 
    #   virgule=$(($virgule - 1))
    elif [[ "$carac" == ')' ]]
    then 
      nbCalcule=$(($nbCalcule - 1))
    fi

    if [[ "$virgule" -eq 0 && "$nbCalcule" -eq 0 && "$carac" == ',' ]]
    then 
      trouv=1
    elif [[ "$carac" == ',' && $nbCalcule -eq 0 ]]
    then 
      param=""
      virgule=$(($virgule - 1))
    else
      param+="$carac"
    fi
    compteur=$(($compteur + 1))
    carac=${1:$compteur:1}
  done
  echo "$param"
}

calcule(){
  
  # $1 -> column without '=' (Ex : =+(2,3) ==> +(2,3))
  # $2 -> file calcule 
  # $3 -> -scin 
  # $4 -> -slout
  # echo "OK"
  trouv=1
  value=$(echo "$1"| sed 's/^[a-z+-/\^\*]*(//; s/.$//')
  res=""
  if [ "${1:0:5}" = 'shell' ]
  then
    # echo "$1"
    trouv=0
    res=$($value)
    echo "${res}"
  fi
  # firstPart=$(echo "$1" | sed 's/.*(//; s/,.*//');
  # secondPart=$(echo "$1" | sed 's/.*,//; s/).*//');
  
  # echo "+(*(4, 5),4)" | sed 's/^.(//; s/.$//'         *(4, 5),4
  if test $trouv == 1
  then
    firstPart=$(getPartOfParam "$value" 1)
    secondPart=$(getPartOfParam "$value" 2)
    # echo $value
    # echo "$ $firstPart / $secondPart $ ))"
    # echo "(( $firstPart // $secondPart ))"
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
      cellule=$(echo `expr $1 : "\(.*\).$"`)
      if [[ "${cellule:1}" =~ $CELLULE && ${1:(-1)} = ']' ]]
      then
        ligne=$( echo "${cellule:1}" | cut -d c -f 1 )
        colonne=$( echo "${cellule:1}" | cut -d c -f 2 )
        res=$(getCase ${ligne:1} ${colonne:0} $2 $3 $4)
        if [[ $res = '' ]]
        then 
          res="=[${ligne}c${colonne}]"
        fi
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
        ligne=$( echo "${firstPart:1}" | cut -d c -f 1 )
        colonne=$( echo "${firstPart:1}" | cut -d c -f 2 )
        res=$(getCase ${ligne:0} ${colonne:0} $2 $3 $4)
        if [[ -f $res ]]
        then
          res=$(wc -c < "$res")
        elif [[ $res = '' ]]
        then
          res="=size($firstPart)"
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
        ligne=$( echo "${firstPart:1}" | cut -d c -f 1 )
        colonne=$( echo "${firstPart:1}" | cut -d c -f 2 )
        res=$(getCase ${ligne:0} ${colonne:0} $2 $3 $4)
        if [[ $res = '=' ]]
        then
          res=$(calcule ${res:1} $2 $3 $4)
        else
          res=$(wc -l < $res)
          res=$(($res + 1))
        fi
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
      
      if [ "${1:0:5}" = 'somme' ]
      then
        res=$(getValueCellule $firstPart $secondPart "$2" "$3" "$4" "$5");
        res=$(sommeCase $res);
      elif [ "${1:0:7}" = 'moyenne' ]
      then
        res=$(getValueCellule $firstPart $secondPart "$2" "$3" "$4" "$5");
        res=$(moyenneCase $res);
      elif [ "${1:0:8}" = 'variance' ]
      then
        res=$(getValueCellule $firstPart $secondPart "$2" "$3" "$4" "$5");

        res=$(varianceCase $res);
      elif [ "${1:0:9}" = 'ecarttype' ]
      then
        res=$(getValueCellule $firstPart $secondPart "$2" "$3" "$4" "$5");
        res=$(ecartTypeCase $res);
      elif [ "${1:0:7}" = 'mediane' ]
      then
        res=$(getValueCellule $firstPart $secondPart "$2" "$3" "$4" "$5");
        res=$(medianeCase $res);
      elif [ "${1:0:4}" = 'mini' ]
      then
        res=$(getValueCellule $firstPart $secondPart "$2" "$3" "$4" "$5");
        res=$(miniCase $res);
      elif [ "${1:0:4}" = 'maxi' ]
      then
        res=$(getValueCellule $firstPart $secondPart "$2" "$3" "$4" "$5");
        res=$(maxiCase $res);
      fi
    fi 

    if [ "$res" = '' ]
    then 

      # echo "$firstPart - $secondPart"
      # exit
      if [[ "$firstPart" =~ $CELLULE ]]
      then
        ligne=$( echo "${firstPart:1}" | cut -d c -f 1 )
        colonne=$( echo "${firstPart:1}" | cut -d c -f 2 )
        firstPart=$(getCase ${ligne:0} ${colonne:0} "$2" "$3" "$4")
      elif ! [[ "$firstPart" =~ $NBR ]]
      then
        # echo "$firstPart"
        firstPart=$(calcule "$firstPart" $2 $3 $4)
      fi

      if [[ "$secondPart" =~ $CELLULE ]]
      then
        ligne=$( echo "${secondPart:1}" | cut -d c -f 1 )
        colonne=$( echo "${secondPart:1}" | cut -d c -f 2 )
        secondPart=$(getCase ${ligne:0} ${colonne:0} "$2" "$3" "$4")
      elif ! [[ "$secondPart" =~ $NBR ]]
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

      if ! [[ "$firstPart" =~ $NBR && "$secondPart" =~ $NBR ]]
      then
        if [[ "${firstPart:0:1}" = '=' ]]
        then
          part1=${firstPart:1}
        else
          part1=$firstPart
        fi
        
        if [[ "${secondPart:0:1}" = '=' ]]
        then
          part2=${secondPart:1}
        else
          part2=$secondPart
        fi

        res="=${1:0:1}($part1,$part2)"
        
      elif [ "${1:0:1}" = '+' ]
      then
        # res="$firstPart-$secondPart"
        res=$(somme $firstPart $secondPart);
        # echo "$firstPart === $secondPart"

      elif [ "${1:0:1}" = '-' ]
      then 
        res=$(difference $firstPart $secondPart);

      elif [ "${1:0:1}" = '*' ]
      then 
        res=$(produit $firstPart $secondPart);
        # res=$firstPart

      elif [ "${1:0:1}" = '/' ]
      then 
        res=$(division $firstPart $secondPart);
        # res="$firstPart-$secondPart"
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
  indexRow=1
  column=$(echo "${1}$2" | cut -d "$2" -f $nbColumn)
  while [ -n "$column" ]
  do
    if test $nbColumn != 1
    then 
      ROW+="$3"
    fi
    if [[ ${column:0:1} = '=' ]]
    then
      res=$(calcule "${column:1}" $4 $2 $5 $indexRow)
      column=$res;
    fi
    ROW+="${column}"
    indexRow=$(($indexRow + 1))
    nbColumn=$(($nbColumn + 1));
    column=$(echo "${1}$2" | cut -d "$2" -f $nbColumn)
  done
  echo $ROW;
}