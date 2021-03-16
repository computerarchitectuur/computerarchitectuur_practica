#!/bin/bash

VALGRIND=/usr/local/bin/valgrind

if [[ "$1" == "" ]]
then
  echo "Gebruik van dit script: $0 <n>"
  exit
fi

n=$1
iteraties=1000
PROG=leonardo

rm ./${PROG}
make pract02

if [ ! -e ./${PROG} ]
then
  echo "Er was een FOUT bij het assembleren van je ${PROG}.s!"
  exit
fi

$VALGRIND --tool=cachegrind --cachegrind-out-file=timing.out ./${PROG} $n $iteraties &> output
cat output | grep leonardo
cat output | grep "Gesimuleerde" # | awk '{print $4}'

echo # Empty line

correctnesscheck() {
   declare -A correctewaarden
   correctewaarden[0]=2
   correctewaarden[1]=2
   correctewaarden[2]=6
   correctewaarden[3]=10
   correctewaarden[4]=18
   correctewaarden[5]=30
   correctewaarden[6]=50
   correctewaarden[7]=82
   correctewaarden[8]=134
   correctewaarden[9]=218
   correctewaarden[10]=354
   correctewaarden[11]=574
   correctewaarden[12]=930
   correctewaarden[13]=1506
   correctewaarden[14]=2438
   correctewaarden[15]=3946
   correctewaarden[16]=6386
   correctewaarden[17]=10334
   correctewaarden[18]=16722
   correctewaarden[19]=27058
   correctewaarden[20]=43782
   correctewaarden[21]=70842
   correctewaarden[22]=114626
   correctewaarden[23]=185470
   correctewaarden[24]=300098
   correctewaarden[25]=485570
   correctewaarden[26]=785670
   correctewaarden[27]=1271242
   correctewaarden[28]=2056914
   correctewaarden[29]=3328158
   correctewaarden[30]=5385074
   correctewaarden[31]=8713234

   result=`./${PROG} $1 1 | cut '-d=' -f3 | cut -'d ' -f2 `
   if [[ "$result" != ${correctewaarden[$1]} ]]
   then
	   echo "Fout! De correcte waarde voor ${PROG}($1) moet ${correctewaarden[$1]} zijn, maar je programma geeft $result terug!"
  fi
}
correctnesscheck 0
correctnesscheck 1
correctnesscheck 2
correctnesscheck 4
correctnesscheck 8
correctnesscheck 16
correctnesscheck $n $k
