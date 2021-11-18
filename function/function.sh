#!/bin/bash

getCase(){
  #  ($1, $2) -> coordinate case
  #  $3 -> file
  #  $4 -> -scin sep
  #  $5 -> -slin sep  

  if test "$5" = '\n'
  then
    sed  $1'!d' $3 | cut -d $4 -f $2
  else
    cut -d $5 -f $1 $3 | cut -d $4 -f $2
  fi

}