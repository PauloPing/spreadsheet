#!/bin/bash

# Groupe de 2   : Louis et Paul 

feuille=0
resultat=0
scinSep=0
slinSep=0
scoutSep=0
sloutSep=0
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
        echo "-in feuille ==> $feuille"
      else 
        echo "Param for -in is not a file, please enter a valid param or remove it!" && exit 1
      fi
    elif [[ ${!compteur} == "-out" ]]
    then 
      if [[ -f $var ]]
      then
        resultat=$var
        echo "-out feuille ==> $resultat"
        else 
        echo "Param for -out is not a file, please enter a valid param or remove it!" && exit 1
      fi
    elif [[ ${!compteur} == "-scin" ]]
    then 
      scinSep=$var
      echo "-scin sep ==> $scinSep"
    elif [[ ${!compteur} == "-slin" ]]
    then 
      slinSep=$var
      echo "-slin sep ==> $slinSep"
    elif [[ ${!compteur} == "-scout" ]]
    then 
      scoutSep=$var
      echo "-scout sep ==> $scoutSep"
    elif [[ ${!compteur} == "-slout" ]]
    then 
      sloutSep=$var
      echo "-slout sep ==> $sloutSep"
    fi
  fi
  compteur=$(($compteur + 1));
done

if [[ ${!compteur} == "-inverse" ]]
then 
  inverse=1
  echo "-inverse ==> $inverse"
fi