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
    # res="line $line"
  else
    if [ -f $3 ]
    then
      res=$(cut -d "$5" -f "$1" "$3" | cut -d "$4" -f "$2")
    else
      res=$(echo "$3" | cut -d "$5" -f "$1" | cut -d "$4" -f "$2" | cut -d "\\" -f 1)
    fi
  fi
  if [[ ${res:0:1} = '=' ]]
  then
    res=$(calcule "${res:1}" "$3" "$4" "$5")
    # res=${res:1}
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

    ligneCellule1="${1:1:1}"
    ligneCellule2="${2:1:1}"
    colonneCellule1="${1:3:1}"
    colonneCellule2="${2:3:1}"

    if [[ $ligneCellule1 =~ $NBR_CASE && $colonneCellule1 =~ $NBR_CASE && $ligneCellule2 =~ $NBR_CASE && $colonneCellule2 =~ $NBR_CASE && $ligneCellule1 -le $ligneCellule2 && $colonneCellule1 -le $colonneCellule2 ]]
    then
      while [[ $ligneCellule1 -le $ligneCellule2 ]]
      do  
        colonne=$colonneCellule1
        while [[ $colonne -le $colonneCellule2 ]]
        do
          value=$(getCase $ligneCellule1 $colonne "$3" "$4" "$5");
          if [[ "$ligneCellule1" -eq "$6" || "$ligneCellule2" -eq "$6" ]]
          then 
            if [[ "$value" = '' ]]
            then 
              noCellule=0
            fi
          fi
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