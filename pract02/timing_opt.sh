#!/bin/bash

VALGRIND=/usr/local/bin/valgrind

if [[ "$1" == "" ]]
then
  echo "Gebruik van dit script: $0 <n>"
  exit
fi

n=$1
iteraties=100

rm ./pell_opt
make pract02_opt

if [ ! -e ./pell_opt ]
then
  echo "Er was een FOUT bij het assembleren van je pell.s!"
  exit
fi

$VALGRIND --tool=cachegrind --cachegrind-out-file=timing.out ./pell_opt $n $iteraties

echo # Empty line

correctnesscheck() {
# for i in `seq 0 22`; do ./pell $i 1 | cut '-d=' -f2 | cut -'d ' -f2 | sed -e "s/^/  correctewaarden[$i]=/" ; done
  correctewaarden[0]=0
  correctewaarden[1]=1
  correctewaarden[2]=2
  correctewaarden[3]=5
  correctewaarden[4]=12
  correctewaarden[5]=29
  correctewaarden[6]=70
  correctewaarden[7]=169
  correctewaarden[8]=408
  correctewaarden[9]=985
  correctewaarden[10]=2378
  correctewaarden[11]=5741
  correctewaarden[12]=13860
  correctewaarden[13]=33461
  correctewaarden[14]=80782
  correctewaarden[15]=195025
  correctewaarden[16]=470832
  correctewaarden[17]=1136689
  correctewaarden[18]=2744210
  correctewaarden[19]=6625109
  correctewaarden[20]=15994428
  correctewaarden[21]=38613965
  correctewaarden[22]=93222358

  i=$n
  result=`./pell_opt $i 1 | cut '-d=' -f2 | cut -'d ' -f2 `
  if [[ "$result" != ${correctewaarden[$i]} ]]
  then
	echo "Fout! De correcte waarde voor pell($i) moet ${correctewaarden[$i]} zijn, maar je programma geeft $result terug!"
  fi
}
correctnesscheck
