#!/bin/bash

NBR_CASE='^[0-9]*$'
CELLULE='^\[(l[0-9]*)c[0-9]*\]$'

getCase(){
  #  ($1, $2) -> coordinate case
  #  $3 -> file
  #  $4 -> -scin sep
  #  $5 -> -slin sep  

  res=""
  if test "$5" = '\n'
  then
      line=$(sed  $1'!d' "$3")
      line="$line$4"
      res=$(echo "$line" | cut -d "$4" -f "$2" | cut -d "\\" -f 1)
  else
    if [ -f "$3" ]
    then
      res=$(cut -d "$5" -f "$1" "$3" | cut -d "$4" -f "$2")
    else
      res=$(echo "$3" | cut -d "$5" -f "$1")
      res=$(echo "$res$4" | cut -d "$4" -f "$2")
    fi
  fi
  if [[ ${res:0:1} = '=' ]]
  then
    res=$(calcule "${res:1}" "$3" "$4" "$5")
  elif [[ $res =~ $CELLULE ]]
  then
    res=$(calcule "${res}" "$3" "$4" "$5")
  fi
  echo "$res"
}

getValueCellule(){
    # $1 ==> cellule1
    # $2 ==> cellule2
    # $3 ==> file 
    # $4 ==> scout
    # $5 ==> slout
    # $6 ==> line number in file

    res=""

    valid=0
    noCellule=1

    ligneCellule1=$( echo "${1:1}" | cut -d "c" -f 1 )
    colonneCellule1=$( echo "${1:1}" | cut -d "c" -f 2 )

    ligneCellule2=$( echo "${2:1}" | cut -d "c" -f 1 )
    colonneCellule2=$( echo "${2:1}" | cut -d "c" -f 2 )

    if [[ $ligneCellule1 =~ $NBR_CASE && $colonneCellule1 =~ $NBR_CASE && $ligneCellule2 =~ $NBR_CASE && $colonneCellule2 =~ $NBR_CASE && $ligneCellule1 -le $ligneCellule2 && $colonneCellule1 -le $colonneCellule2 ]]
    then
      while [[ $ligneCellule1 -le $ligneCellule2 ]]
      do  
        colonne=$colonneCellule1
        while [[ $colonne -le $colonneCellule2 ]]
        do
          value=$(getCase "$ligneCellule1" "$colonne" "$3" "$4" "$5");
          if [ "$value" != '' ]
          then
            valid=1
          elif [[ $value =~ $CELLULE ]]
          then
            noCellule=0
          fi
          res+="$value,"
          colonne=$(($colonne + 1))
        done
        colonne=colonneCellule1;
        ligneCellule1=$(($ligneCellule1 + 1))
      done
      res+="END"
    fi
    if [[ $valid -eq 1 && $noCellule -eq 1 ]]
    then
      echo $res
    else
      echo "NULL"
    fi
}

returnValueCelluleInResult(){
    # $1 ==> feuille
    # $2 ==> separateur de col
    # $3 ==> celluleX 
    # $4 ==> celluleY

    res=""
    valid=1

    if [[ "$3" != "" && "$4" != "" ]]
    then
      ligneCellule1=$( echo "${3:1}" | cut -d "c" -f 1 )
      colonneCellule1=$( echo "${3:1}" | cut -d "c" -f 2 )

      ligneCellule2=$( echo "${4:1}" | cut -d "c" -f 1 )
      colonneCellule2=$( echo "${4:1}" | cut -d "c" -f 2 )

      if [[ $ligneCellule1 =~ $NBR_CASE && $colonneCellule1 =~ $NBR_CASE && $ligneCellule2 =~ $NBR_CASE && $colonneCellule2 =~ $NBR_CASE && $ligneCellule1 -le $ligneCellule2 && $colonneCellule1 -le $colonneCellule2 ]]
      then
        while [[ $ligneCellule1 -le $ligneCellule2 ]]
        do  
          ligne=""
          colonne=$colonneCellule1
          while [[ $colonne -le $colonneCellule2 && $valid -eq 1 ]]
          do
            value=$(getCase "$ligneCellule1" "$colonne" "$1" "$2" "$");
            if [ "$value" != '' ]
            then
              valid=1
              ligne+="$value$2"
              colonne=$(($colonne + 1))
            else 
              valid=0
            fi
          done
          colonne=colonneCellule1;
          res+="$(echo $ligne | sed 's/.$//')"
          res+="$"
          ligneCellule1=$(($ligneCellule1 + 1))
        done
      fi
      echo "$res"
    else
      echo "$res"
    fi
}