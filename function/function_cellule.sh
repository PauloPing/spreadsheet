#!/bin/bash

NBR_CASE='^[0-9]*$'

getCase(){
  #  ($1, $2) -> coordinate case
  #  $3 -> file
  #  $4 -> -scin sep
  #  $5 -> -slin sep  

  if test "$5" = '\n'
  then
    # line=$(sed  $1'!d' $3)
    sed  $1'!d' $3 | cut -d $4 -f $2 | cut -d "\\" -f 1
  else
    cut -d $5 -f $1 $3 | cut -d $4 -f $2
  fi
}

getValueCellule(){
    # $1 ==> cellule1
    # $2 ==> cellule2
    # $3 ==> file 
    # $4 ==> scout
    # $5 ==> slout

    res=""

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
          res+=$(getCase $ligneCellule1 $colonne $3 $4 $5);
          res+=","
          colonne=$(($colonne + 1))
        done
        colonne=colonneCellule1;
        ligneCellule1=$(($ligneCellule1 + 1))
      done
      res+="END"
    fi
    echo $res
}