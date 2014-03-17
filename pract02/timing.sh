#!/bin/bash

VALGRIND=/usr/local/bin/valgrind

if [[ "$1" == "" ]]
then
  echo "Gebruik van dit script: $0 <n>"
  exit
fi

n=$1
iteraties=1000
PROG=jacobsthal

rm ./${PROG}
make pract02

if [ ! -e ./${PROG} ]
then
  echo "Er was een FOUT bij het assembleren van je ${PROG}.s!"
  exit
fi

$VALGRIND --tool=cachegrind --cachegrind-out-file=timing.out ./${PROG} $n $iteraties &> output
cat output | grep Jacobsthal 
cat output | grep "Gesimuleerde" # | awk '{print $4}'

echo # Empty line

correctnesscheck() {
   correctewaarden[0]=0
   correctewaarden[1]=1
   correctewaarden[2]=1
   correctewaarden[3]=3
   correctewaarden[4]=5
   correctewaarden[5]=11
   correctewaarden[6]=21
   correctewaarden[7]=43
   correctewaarden[8]=85
   correctewaarden[9]=171
   correctewaarden[10]=341
   correctewaarden[11]=683
   correctewaarden[12]=1365
   correctewaarden[13]=2731
   correctewaarden[14]=5461
   correctewaarden[15]=10923
   correctewaarden[16]=21845
   correctewaarden[17]=43691
   correctewaarden[18]=87381
   correctewaarden[19]=174763
   correctewaarden[20]=349525
   correctewaarden[21]=699051
   correctewaarden[22]=1398101
   
   i=$n
   result=`./${PROG} $i 1 | cut '-d=' -f2 | cut -'d ' -f2 `
   if [[ "$result" != ${correctewaarden[$i]} ]]
   then
	   echo "Fout! De correcte waarde voor ${PROG}($i) moet ${correctewaarden[$i]} zijn, maar je programma geeft $result terug!"
  fi
}
correctnesscheck
