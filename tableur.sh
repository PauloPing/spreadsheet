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

if [ -z $feuille ];
then 
  echo "No file for the param -in, writing in the terminal ... "
else 
  nbRow=1
  row=$(echo "$g" | sed  $nbRow'!d' $feuille )
  while [ ! "$row" = "$g" ]
  do      
    res=$(rowToResultFile $row $scinSep $scoutSep $result)
    echo $res;
    if test $result != 0
    then
      printf "$res$sloutSep" >> $result
    else
      if test $sloutSep != '\n'
      then 
        echo "$res$sloutSep"
      else
        echo "$res"
      fi
    fi
    nbRow=$(($nbRow + 1))
    row=$(echo "$g" | sed  $nbRow'!d' calcule )
  done
fi

# res=$(getCase 3 2 $feuille $scinSep $slinSep)
# echo "chifffre : "$res;

# echo $character
# res=$(somme 1 2)
# echo "chifffre : "$res;















# while read -n1 c; do
  #   character=$(($character + 1))
  #   if [ -z $result ]
  #   then
  #     echo "No file for the param -out, result in terminal"
  #   else 
  #     if test "$c" != '=' && test "$c" != $scinSep && test "$c" != $slinSep && test "$c" != ''
  #     then
  #       printf "$c" >> $result
  #     elif test "$c" == '='
  #     then
  #       printf "FUNC" >> $result
  #     elif test "$c" == $scinSep
  #     then
  #       printf $scoutSep >> $result
  #     elif [[ "$c" = "$slinSep" || "$c" = '' ]]
  #     then
  #       printf $sloutSep >> $result
  #     fi
  #   fi
  # done < $feuille