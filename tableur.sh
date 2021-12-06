#!/bin/bash

# Groupe de 2   : Louis et Paul 


source ./function/calc.sh
source ./function/function.sh

feuille=0
result=0
scinSep="\t"
slinSep="\n"
inverse=0

compteur=0

# check param
for var in $@
do
  paramValide=$((compteur % 2))
  if [ $paramValide -eq 1 ]
  then 
    if [[ ${!compteur} == "-in" ]]
    then 
      if [[ -f $var ]]
      then
        feuille=$var
      else 
        echo "Param for -in is not a file, please enter a valid param or remove it!" && exit 1
      fi
    elif [[ ${!compteur} == "-out" ]]
    then 
      if [[ -f $var ]]
      then
        result=$var
        else 
        echo "Param for -out is not a file, please enter a valid param or remove it!" && exit 1
      fi
    elif [[ ${!compteur} == "-scin" ]]
    then 
      scinSep=$var
    elif [[ ${!compteur} == "-slin" ]]
    then 
      slinSep=$var
    elif [[ ${!compteur} == "-scout" ]]
    then 
      scoutSep=$var
    elif [[ ${!compteur} == "-slout" ]]
    then 
      sloutSep=$var
    fi
  fi
  compteur=$(($compteur + 1));
done

if [[ ${!compteur} == "-inverse" ]]
then 
  inverse=1
fi

# Init param scout & slout, if the param isn't enter in shell command (scout = scin & slout = slin)
if [[ ! $scoutSep ]]
then 
  scoutSep=$scinSep
fi

if [[ ! $sloutSep ]]
then 
  sloutSep=$slinSep
fi

# To delete the text already present in the file
if [ -f $result ]
then  
  > $result
fi


echo "feuille : $feuille"
echo "result : $result"
echo "scinSep : $scinSep"
echo "slinSep : $slinSep"
echo "scoutSep : $scoutSep"
echo "sloutSep : $sloutSep"
echo "inverse : $inverse"

character=0

premierCalculte=""

if test $feuille = 0
then 
  ligne=""
  feuille=""
  echo "No file for the param -in, writing in the terminal... Write an empty line to validate!"
  read ligne
  while test "$ligne" != ""
  do
    if test $slinSep = '\n' 
    then
      ligne="$ligne$"
    fi
    feuille+="$ligne"
    ligne="" 
    read ligne
  done
  # echo -e $feuille
fi

echo "Calcule en cours ..."
nbRow=1
if [[ -f $feuille ]]
then
  if test $slinSep != '\n'
  then
    row=$(cat "$feuille" | cut -d "$slinSep" -f "$nbRow")
  else
    row=$(echo "$g" | sed  $nbRow'!d' "$feuille")
  fi
  sepa="$slinSep"
else
  sepa="$"
  if test $slinSep != '\n'
  then
    sepa="$slinSep"
  fi
  row=$(echo -n "$feuille" | cut -d"$sepa" -f $nbRow)
fi

feuilleInverse=""
celluleDisplayX=""
celulleDisplayY=""
while [ ! "$row" = "$g" ]
do      
  res=$(rowToResultFile "$row" "$scinSep" "$scoutSep" "$feuille" "$sepa")
  display=$(echo "$row" | grep -Eo "=display\([c,l,0-9]*\)*\)" | cut -d "(" -f 2 | cut -d ")" -f 1)
  if test "$display" != ''
  then
    celluleDisplayX+=$(echo "$display" | cut -d ',' -f 1 )
    celluleDisplayX+="-"
    celluleDisplayY+=$(echo "$display" | cut -d ',' -f 2 )
    celluleDisplayY+="-"
  fi
  feuilleInverse+="${res}$"
  nbRow=$(($nbRow + 1))
  if [[ -f $feuille ]]
  then
    if test $slinSep != '\n'
    then
      row=$(cat "$feuille" | cut -d"$slinSep" -f "$nbRow")
    else
      row=$(echo "$g" | sed  $nbRow'!d' "$feuille" )
    fi
  else
    sepa="$"
    if test $slinSep != '\n'
    then
      sepa="$slinSep"
    fi
    row=$(echo -e "$feuille" | cut -d "$sepa" -f $nbRow)
  fi
done

nbRow=$(($nbRow - 1))
compteur=1
if test $inverse = 1
then 
  nbColumn=1
  res=$(getValueCellule "l1c${nbColumn}" "l${nbRow}c${nbColumn}" "$feuilleInverse" "$scoutSep" "$")
  while test "$res" != "NULL"
  do
    compteur=1
    myLign=""
    col=$(echo "$res" | cut -d "," -f "$compteur")
    while test "$col" != "END"
    do
      if test $compteur != 1
      then
        myLign+="$scoutSep"
      fi
      myLign+="$col"
      compteur=$(($compteur + 1))
      col=$(echo "$res" | cut -d "," -f "$compteur")
    done
    if [ -f $result ]
    then
      if test "$sloutSep" != '\n'
      then 
        echo -n "$myLign$sloutSep" >> $result
      else
        echo "$myLign" >> $result
      fi
    else
      echo "$myLign"
    fi
    nbColumn=$(($nbColumn + 1))
    compteur=$(($compteur + 1))
    res=$(getValueCellule "l1c${nbColumn}" "l${nbRow}c${nbColumn}" "$feuilleInverse" "$scoutSep" "$")
  done
else
  nbRow=1
  display=1
  sepa="$"
  if test "$celluleDisplayX" == ''
  then
    row=$(echo "$feuilleInverse" | cut -d "$sepa" -f $nbRow)
  else
    displayX=$(echo "$celluleDisplayX" | cut -d '-' -f $display)
    displayY=$(echo "$celluleDisplayY" | cut -d '-' -f $display)
    row=$(returnValueCelluleInResult $feuilleInverse $scoutSep $displayX $displayY)
  fi
  while [ ! "$row" = "$g" ]
  do
    if test "$celluleDisplayX" == ''
    then
      if test $result != 0
      then
        if test $sloutSep = '\n'
        then
          printf "%s\n" ${row} >> $result
        else
          printf "%s%c" ${row}${sloutSep} >> $result
        fi
      else
        if test "$sloutSep" != '\n'
        then 
          echo -n "$row$sloutSep"
        else
          echo "$row"
        fi
      fi
    else
      nbRowAffichage=1
      affichage=$(echo "$row" | cut -d "$" -f $nbRowAffichage)
      while test "$affichage" != ""
      do
        if [ -f $result ]
        then
          if test "$sloutSep" != '\n'
          then
            echo "$affichage$sloutSep" >> $result
          else
            echo "$affichage" >> $result
          fi
        else
          if test "$sloutSep" != '\n'
          then
            echo "$affichage$sloutSep"
          else
            echo -e "$affichage"
          fi
        fi
        nbRowAffichage=$(($nbRowAffichage + 1))
        affichage=$(echo "$row" | cut -d "$" -f $nbRowAffichage)
      done
    fi
    if test "$celluleDisplayX" == ''
    then
      nbRow=$(($nbRow + 1))
      row=$(echo "$feuilleInverse" | cut -d "$sepa" -f $nbRow)
    else
      display=$(($display + 1))
      displayX=$(echo "$celluleDisplayX" | cut -d "-" -f $display)
      displayY=$(echo "$celluleDisplayY" | cut -d "-" -f $display)
      row=$(returnValueCelluleInResult $feuilleInverse $scoutSep $displayX $displayY)
    fi
  done
fi