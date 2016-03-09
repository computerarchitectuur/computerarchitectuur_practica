#!/bin/bash

VALGRIND=/usr/local/bin/valgrind

if [[ "$1" == "" ]]
then
  echo "Gebruik van dit script: $0 <n>"
  exit
fi

n=$1
iteraties=1000
PROG=padovan

rm ./${PROG}
make pract02

if [ ! -e ./${PROG} ]
then
  echo "Er was een FOUT bij het assembleren van je ${PROG}.s!"
  exit
fi

$VALGRIND --tool=cachegrind --cachegrind-out-file=timing.out ./${PROG} $n $iteraties &> output
cat output | grep padovan
cat output | grep "Gesimuleerde" # | awk '{print $4}'

echo # Empty line

correctnesscheck() {
  correctewaarden[1]=1
  correctewaarden[2]=1
  correctewaarden[3]=1
  correctewaarden[4]=2
  correctewaarden[5]=2
  correctewaarden[6]=3
  correctewaarden[7]=4
  correctewaarden[8]=5
  correctewaarden[9]=7
  correctewaarden[10]=9
  correctewaarden[11]=12
  correctewaarden[12]=16
  correctewaarden[13]=21
  correctewaarden[14]=28
  correctewaarden[15]=37
  correctewaarden[16]=49
  correctewaarden[17]=65
  correctewaarden[18]=86
  correctewaarden[19]=114
  correctewaarden[20]=151
  correctewaarden[21]=200
  correctewaarden[22]=265
  correctewaarden[23]=351
  correctewaarden[24]=465
  correctewaarden[25]=616
  correctewaarden[26]=816
  correctewaarden[27]=1081
  correctewaarden[28]=1432
  correctewaarden[29]=1897
  correctewaarden[30]=2513
  correctewaarden[31]=3329
  correctewaarden[32]=4410
  correctewaarden[33]=5842

   i=$n
   result=`./${PROG} $i 1 | cut '-d=' -f2 | cut -'d ' -f2 `
   if [[ "$result" != ${correctewaarden[$i]} ]]
   then
	   echo "Fout! De correcte waarde voor ${PROG}($i) moet ${correctewaarden[$i]} zijn, maar je programma geeft $result terug!"
  fi
}
correctnesscheck
