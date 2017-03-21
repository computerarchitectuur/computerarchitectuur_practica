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
   correctewaarden[0]=1
   correctewaarden[1]=1
   correctewaarden[2]=1
   correctewaarden[3]=2
   correctewaarden[4]=2
   correctewaarden[5]=3
   correctewaarden[6]=4
   correctewaarden[7]=5
   correctewaarden[8]=7
   correctewaarden[9]=9
   correctewaarden[10]=12
   correctewaarden[11]=16
   correctewaarden[12]=21
   correctewaarden[13]=28
   correctewaarden[14]=37
   correctewaarden[15]=49
   correctewaarden[16]=65
   correctewaarden[17]=86
   correctewaarden[18]=114
   correctewaarden[19]=151
   correctewaarden[20]=200
   correctewaarden[21]=265
   correctewaarden[22]=351
   correctewaarden[23]=465
   correctewaarden[24]=616
   correctewaarden[25]=816
   correctewaarden[26]=1081
   correctewaarden[27]=1432
   correctewaarden[28]=1897
   correctewaarden[29]=2513
   correctewaarden[30]=3329
   correctewaarden[31]=4410
   correctewaarden[32]=5842
   correctewaarden[33]=7739

   i=$n
   result=`./${PROG} $i 1 | cut '-d=' -f2 | cut -'d ' -f2 `
   if [[ "$result" != ${correctewaarden[$i]} ]]
   then
	   echo "Fout! De correcte waarde voor ${PROG}($i) moet ${correctewaarden[$i]} zijn, maar je programma geeft $result terug!"
  fi
}
correctnesscheck
