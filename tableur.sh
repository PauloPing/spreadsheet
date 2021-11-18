#!/bin/bash

# Groupe de 2   : Louis et Paul 


source ./function/calc.sh
source ./function/function.sh

scinSep="\t"
slinSep="\n"
inverse=0

compteur=0
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
        resultat=$var
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

if [[ ! $scoutSep ]]
then 
  scoutSep=$scinSep
fi

if [[ ! $sloutSep ]]
then 
  sloutSep=$slinSep
fi

# To delete the text already present in the file
if [ -f $resultat ]
then  
  > $resultat
fi

echo "feuille : $feuille"
echo "resultat : $resultat"
echo "scinSep : $scinSep"
echo "slinSep : $slinSep"
echo "scoutSep : $scoutSep"
echo "sloutSep : $sloutSep"
echo "inverse : $inverse"

character=0
# sed -n '${count}p' hearders.txt => reprendre un fichier au '${count}p' ieme caractère (PAS TEST)

if [ -z $feuille ];
then 
  echo "No file for the param -in, writing in the terminal ... "
else 
  while read -n1 c; do
    character=$(($character + 1))
    if [ -z $resultat ]
    then
      echo "No file for the param -out, result in terminal"
    else 
      if test "$c" != '=' && test "$c" != $scinSep && test "$c" != $slinSep && test "$c" != ''
      then
        printf "$c" >> $resultat
      elif test "$c" == '='
      then
        printf "FUNC" >> $resultat
      elif test "$c" == $scinSep
      then
        printf $scoutSep >> $resultat
      elif [[ "$c" = "$slinSep" || "$c" = '' ]]
      then
        printf $sloutSep >> $resultat
      fi
    fi
  done < $feuille
fi

res=$(getCase 3 2 $feuille $scinSep $slinSep)
echo "chifffre : "$res;

# echo $character
# res=$(somme 1 2)
# echo "chifffre : "$res;
