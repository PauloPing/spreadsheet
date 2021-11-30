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

# Param inverse ### A CORRIGER : FONCTIONNE PAS SI -inverse N'EST PAS EN DERNIER PARAM
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
    row=$(cat $feuille | cut -d"$slinSep" -f $nbRow)
  else
    row=$(echo "$g" | sed  $nbRow'!d' $feuille )
  fi
else
  sepa="$"
  if test $slinSep != '\n'
  then
    sepa="$slinSep"
  fi
  row=$(echo -n $feuille | cut -d"$sepa" -f $nbRow)
fi

while [ ! "$row" = "$g" ]
do      
  res=$(rowToResultFile "$row" $scinSep $scinSep $result $sloutSep)
  # echo $res;
  if test $result != "0"
  then
    if test $sloutSep = '\n'
    then
      premierCalculte+="${res}$"
      printf "%s\n" ${res} >> $result
    else
      premierCalculte+="${res}${sloutSep}"
      printf "%s%c" ${res}${sloutSep} >> $result
    fi
  else
    if test "$sloutSep" != '\n'
    then 
      echo "$res$sloutSep"
    else
      echo "$res"
    fi
  fi
  nbRow=$(($nbRow + 1))
  if [[ -f $feuille ]]
  then
    if test $slinSep != '\n'
    then
      row=$(cat $feuille | cut -d"$slinSep" -f $nbRow)
    else
      row=$(echo "$g" | sed  $nbRow'!d' $feuille )
    fi
  else
    sepa="$"
    if test $slinSep != '\n'
    then
      sepa="$slinSep"
    fi
    row=$(echo -n $feuille | cut -d"$sepa" -f $nbRow)
  fi
done

feuille=$premierCalculte


nbRow=1
sepa="$"
if test $slinSep != '\n'
then
  sepa="$slinSep"
fi
row=$(echo -n $feuille | cut -d"$sepa" -f $nbRow)

> $result

while [ ! "$row" = "$g" ]
do      
  res=$(rowToResultFile "$row" $scinSep $scoutSep $premierCalculte '$')
  echo "$res"
  if test $result != "0"
  then
    if test $sloutSep = '\n'
    then
      printf "%s\n" ${res} >> $result
    else
      printf "%s%c" ${res}${sloutSep} >> $result
    fi
  else
    if test "$sloutSep" != '\n'
    then 
      echo "$res$sloutSep"
    else
      echo "$res"
    fi
  fi
  nbRow=$(($nbRow + 1))
  row=$(echo -n $feuille | cut -d"$sepa" -f $nbRow)
done