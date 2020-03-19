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
   correctewaarden[0]=1
   correctewaarden[1]=1
   correctewaarden[2]=3
   correctewaarden[3]=5
   correctewaarden[4]=9
   correctewaarden[5]=15
   correctewaarden[6]=25
   correctewaarden[7]=41
   correctewaarden[8]=67
   correctewaarden[9]=109
   correctewaarden[10]=177
   correctewaarden[11]=287
   correctewaarden[12]=465
   correctewaarden[13]=753
   correctewaarden[14]=1219
   correctewaarden[15]=1973
   correctewaarden[16]=3193
   correctewaarden[17]=5167
   correctewaarden[18]=8361
   correctewaarden[19]=13529
   correctewaarden[20]=21891
   correctewaarden[21]=35421
   correctewaarden[22]=57313
   correctewaarden[23]=92735
   correctewaarden[24]=150049
   correctewaarden[25]=242785
   correctewaarden[26]=392835
   correctewaarden[27]=635621
   correctewaarden[28]=1028457
   correctewaarden[29]=1664079
   correctewaarden[30]=2692537
   correctewaarden[31]=4356617

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
