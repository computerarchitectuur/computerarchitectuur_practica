#!/bin/bash

VALGRIND=valgrind

get_nr_cycles() {
	if [ ! -e timing.out ]; then
		return 0
	fi

	Instr=$(tail -1 timing.out | cut -d " " -f 2)
	Data_read=$(tail -1 timing.out | cut -d " " -f 5)
	Data_write=$(tail -1 timing.out | cut -d " " -f 8)

	total_cycles=$(($Instr + 153 * ($Data_read + $Data_write)))
}


if [[ "$1" == "" ]]
then
  echo "Gebruik van dit script: $0 <n>"
  exit
fi

n=$1
iteraties=1000
if [ -n "$2" ]; then
	iteraties=$2
fi
PROG=narayana

rm ./${PROG}
make pract02

if [ ! -e ./${PROG} ]
then
  echo "Er was een FOUT bij het assembleren van je ${PROG}.s!"
  exit
fi

$VALGRIND --tool=cachegrind --cachegrind-out-file=timing.out ./${PROG} $n $iteraties &> output
cat output | grep Narayana 
#cat output | grep "Gesimuleerde" # | awk '{print $4}'
get_nr_cycles
echo "Gesimuleerd: $total_cycles cycli"


echo # Empty line

correctnesscheck() {
   correctewaarden[0]=1
   correctewaarden[1]=1
   correctewaarden[2]=1
   correctewaarden[3]=2
   correctewaarden[4]=3
   correctewaarden[5]=4
   correctewaarden[6]=6
   correctewaarden[7]=9
   correctewaarden[8]=13
   correctewaarden[9]=19
   correctewaarden[10]=28
   correctewaarden[11]=41
   correctewaarden[12]=60
   correctewaarden[13]=88
   correctewaarden[14]=129
   correctewaarden[15]=189
   correctewaarden[16]=277
   correctewaarden[17]=406
   correctewaarden[18]=595
   correctewaarden[19]=872
   correctewaarden[20]=1278
   correctewaarden[21]=1873
   correctewaarden[22]=2745
   
   i=$n
   result=`./${PROG} $i 1 | cut '-d=' -f2 | cut -'d ' -f2 `
   if [[ "$result" != ${correctewaarden[$i]} ]]
   then
	   echo "Fout! De correcte waarde voor ${PROG}($i) moet ${correctewaarden[$i]} zijn, maar je programma geeft $result terug!"
  fi
}
correctnesscheck
