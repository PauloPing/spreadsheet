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
# sed -n '${count}p' hearders.txt => reprendre un fichier au '${count}p' ieme caractère (PAS TEST)

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

nbRow=1
if [[ -f $feuille ]]
then
  if test $slinSep != '\n'
  then
    row=$(cat "$feuille" | cut -d "$slinSep" -f $nbRow)
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
while [ ! "$row" = "$g" ]
do      
  res=$(rowToResultFile "$row" "$scinSep" "$scoutSep" "$feuille" "$sepa")
  # echo $res;
  if test $result != "0"
  then
    if test $sloutSep = '\n'
    then
      if test $inverse = 1
      then
        feuilleInverse+="${res}$"
      else
        printf "%s\n" ${res} >> $result
      fi
    else
      if test $inverse = 1
      then
        feuilleInverse+="${res}$"
      else
        printf "%s%c" ${res}${sloutSep} >> $result
      fi
      # feuilleInverse+="${res}${sloutSep}"
    fi
  else
    if test "$sloutSep" != '\n'
    then 
      feuilleInverse+="$res$"
      if test $inverse != 1
      then
        echo "$res$sloutSep"
      fi
    else
      feuilleInverse+="$res$"
      if test $inverse != 1
      then
        echo "$res"
      fi
    fi
  fi
  nbRow=$(($nbRow + 1))
  if [[ -f $feuille ]]
  then
    if test $slinSep != '\n'
    then
      row=$(cat "$feuille" | cut -d"$slinSep" -f $nbRow)
    else
      row=$(echo "$g" | sed  $nbRow'!d' $feuille )
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

# echo $feuilleInverse

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
        echo "$myLign" >> $result
    else
      echo "$myLign"
    fi
    nbColumn=$(($nbColumn + 1))
    compteur=$(($compteur + 1))
    res=$(getValueCellule "l1c${nbColumn}" "l${nbRow}c${nbColumn}" "$feuilleInverse" "$scoutSep" "$")
  done
fi

