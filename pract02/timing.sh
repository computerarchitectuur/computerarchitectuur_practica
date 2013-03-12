#!/bin/bash

VALGRIND=/usr/local/bin/valgrind

if [[ "$1" == "" ]]
then
  echo "Gebruik van dit script: $0 <n>"
  exit
fi

n=$1
iteraties=1000
PROG=lucas

rm ./${PROG}
make pract02

if [ ! -e ./${PROG} ]
then
  echo "Er was een FOUT bij het assembleren van je ${PROG}.s!"
  exit
fi

$VALGRIND --tool=cachegrind --cachegrind-out-file=timing.out ./${PROG} $n $iteraties &> output
cat output | grep Lucas 
cat output | grep "Gesimuleerde" # | awk '{print $4}'

echo # Empty line

correctnesscheck() {
   correctewaarden[0]=2
   correctewaarden[1]=2
   correctewaarden[2]=6
   correctewaarden[3]=10
   correctewaarden[4]=22
   correctewaarden[5]=42
   correctewaarden[6]=86
   correctewaarden[7]=170
   correctewaarden[8]=342
   correctewaarden[9]=682
   correctewaarden[10]=1366
   correctewaarden[11]=2730
   correctewaarden[12]=5462
   correctewaarden[13]=10922
   correctewaarden[14]=21846
   correctewaarden[15]=43690
   correctewaarden[16]=87382
   correctewaarden[17]=174762
   correctewaarden[18]=349526
   correctewaarden[19]=699050
   correctewaarden[20]=1398102
   correctewaarden[21]=2796202
   correctewaarden[22]=5592406
   
   i=$n
   result=`./${PROG} $i 1 | cut '-d=' -f2 | cut -'d ' -f2 `
   if [[ "$result" != ${correctewaarden[$i]} ]]
   then
	   echo "Fout! De correcte waarde voor ${PROG}($i) moet ${correctewaarden[$i]} zijn, maar je programma geeft $result terug!"
  fi
}
correctnesscheck
