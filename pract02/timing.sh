#!/bin/bash

VALGRIND=/usr/local/bin/valgrind

if [[ "$1" == "" ]]
then
  echo "Gebruik van dit script: $0 <n>"
  exit
fi

n=$1
iteraties=1000
PROG=perrin

rm ./${PROG}
make pract02

if [ ! -e ./${PROG} ]
then
  echo "Er was een FOUT bij het assembleren van je ${PROG}.s!"
  exit
fi

$VALGRIND --tool=cachegrind --cachegrind-out-file=timing.out ./${PROG} $n $iteraties &> output
cat output | grep perrin
cat output | grep "Gesimuleerde" # | awk '{print $4}'

echo # Empty line

correctnesscheck() {
   correctewaarden[0]=3
   correctewaarden[1]=0
   correctewaarden[2]=2
   correctewaarden[3]=3
   correctewaarden[4]=2
   correctewaarden[5]=5
   correctewaarden[6]=5
   correctewaarden[7]=7
   correctewaarden[8]=10
   correctewaarden[9]=12
   correctewaarden[10]=17
   correctewaarden[11]=22
   correctewaarden[12]=29
   correctewaarden[13]=39
   correctewaarden[14]=51
   correctewaarden[15]=68
   correctewaarden[16]=90
   correctewaarden[17]=119
   correctewaarden[18]=158
   correctewaarden[19]=209
   correctewaarden[20]=277
   correctewaarden[21]=367
   correctewaarden[22]=486
   correctewaarden[23]=644
   correctewaarden[24]=853
   correctewaarden[25]=1130
   correctewaarden[26]=1497
   correctewaarden[27]=1983
   correctewaarden[28]=2627
   correctewaarden[29]=3480
   correctewaarden[30]=4610
   correctewaarden[31]=6107
   correctewaarden[32]=8090
   correctewaarden[33]=10717

   i=$n
   result=`./${PROG} $i 1 | cut '-d=' -f2 | cut -'d ' -f2 `
   if [[ "$result" != ${correctewaarden[$i]} ]]
   then
	   echo "Fout! De correcte waarde voor ${PROG}($i) moet ${correctewaarden[$i]} zijn, maar je programma geeft $result terug!"
  fi
}
correctnesscheck
