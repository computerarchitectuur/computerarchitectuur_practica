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
cat output | grep jacobsthal
cat output | grep "Gesimuleerde" # | awk '{print $4}'

echo # Empty line

correctnesscheck() {
   declare -A correctewaarden
   correctewaarden[0]=1 
   correctewaarden[1]=1 
   correctewaarden[2]=3 
   correctewaarden[3]=5 
   correctewaarden[4]=11 
   correctewaarden[5]=21 
   correctewaarden[6]=43 
   correctewaarden[7]=85 
   correctewaarden[8]=171 
   correctewaarden[9]=341 
   correctewaarden[10]=683 
   correctewaarden[11]=1365 
   correctewaarden[12]=2731 
   correctewaarden[13]=5461 
   correctewaarden[14]=10923 
   correctewaarden[15]=21845 
   correctewaarden[16]=43691 
   correctewaarden[17]=87381 
   correctewaarden[18]=174763 
   correctewaarden[19]=349525 
   correctewaarden[20]=699051 
   correctewaarden[21]=1398101 
   correctewaarden[22]=2796203 
   correctewaarden[23]=5592405 
   correctewaarden[24]=11184811 
   correctewaarden[25]=22369621 
   correctewaarden[26]=44739243 
   correctewaarden[27]=89478485 
   correctewaarden[28]=178956971 
   correctewaarden[29]=357913941 
   correctewaarden[30]=715827883 
   correctewaarden[31]=1431655765 


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
