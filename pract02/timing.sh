#!/bin/bash

VALGRIND=/usr/local/bin/valgrind

if [[ "$2" == "" ]]
then
  echo "Gebruik van dit script: $0 <n> <k>"
  exit
fi

n=$1
k=$2
iteraties=1000
PROG=binomial

rm ./${PROG}
make pract02

if [ ! -e ./${PROG} ]
then
  echo "Er was een FOUT bij het assembleren van je ${PROG}.s!"
  exit
fi

$VALGRIND --tool=cachegrind --cachegrind-out-file=timing.out ./${PROG} $n $k $iteraties &> output
cat output | grep binomial
cat output | grep "Gesimuleerde" # | awk '{print $4}'

echo # Empty line

correctnesscheck() {
   declare -A correctewaarden
   correctewaarden[0,0]=1
   correctewaarden[1,0]=1                                                                                                                                                         
   correctewaarden[1,1]=1                                                                                                                                                         
   correctewaarden[2,0]=1                                                                                                                                                         
   correctewaarden[2,1]=2                                                                                                                                                         
   correctewaarden[2,2]=1                                                                                                                                                         
   correctewaarden[3,0]=1                                                                                                                                                         
   correctewaarden[3,1]=3                                                                                                                                                         
   correctewaarden[3,2]=3                                                                                                                                                         
   correctewaarden[3,3]=1                                                                                                                                                         
   correctewaarden[4,0]=1                                                                                                                                                         
   correctewaarden[4,1]=4                                                                                                                                                         
   correctewaarden[4,2]=6                                                                                                                                                         
   correctewaarden[4,3]=4                                                                                                                                                         
   correctewaarden[4,4]=1                                                                                                                                                         
   correctewaarden[5,0]=1                                                                                                                                                         
   correctewaarden[5,1]=5
   correctewaarden[5,2]=10
   correctewaarden[5,3]=10
   correctewaarden[5,4]=5
   correctewaarden[5,5]=1
   correctewaarden[6,0]=1
   correctewaarden[6,1]=6
   correctewaarden[6,2]=15
   correctewaarden[6,3]=20
   correctewaarden[6,4]=15
   correctewaarden[6,5]=6
   correctewaarden[6,6]=1
   correctewaarden[7,0]=1
   correctewaarden[7,1]=7
   correctewaarden[7,2]=21
   correctewaarden[7,3]=35
   correctewaarden[7,4]=35
   correctewaarden[7,5]=21
   correctewaarden[7,6]=7
   correctewaarden[7,7]=1
   correctewaarden[8,0]=1
   correctewaarden[8,1]=8
   correctewaarden[8,2]=28
   correctewaarden[8,3]=56
   correctewaarden[8,4]=70
   correctewaarden[8,5]=56
   correctewaarden[8,6]=28
   correctewaarden[8,7]=8
   correctewaarden[8,8]=1
   correctewaarden[9,0]=1
   correctewaarden[9,1]=9
   correctewaarden[9,2]=36
   correctewaarden[9,3]=84
   correctewaarden[9,4]=126
   correctewaarden[9,5]=126
   correctewaarden[9,6]=84
   correctewaarden[9,7]=36
   correctewaarden[9,8]=9
   correctewaarden[9,9]=1
   correctewaarden[10,0]=1
   correctewaarden[10,1]=10
   correctewaarden[10,2]=45
   correctewaarden[10,3]=120
   correctewaarden[10,4]=210
   correctewaarden[10,5]=252
   correctewaarden[10,6]=210
   correctewaarden[10,7]=120
   correctewaarden[10,8]=45
   correctewaarden[10,9]=10
   correctewaarden[10,10]=1
   correctewaarden[11,0]=1
   correctewaarden[11,1]=11
   correctewaarden[11,2]=55
   correctewaarden[11,3]=165
   correctewaarden[11,4]=330
   correctewaarden[11,5]=462
   correctewaarden[11,6]=462
   correctewaarden[11,7]=330
   correctewaarden[11,8]=165
   correctewaarden[11,9]=55
   correctewaarden[11,10]=11
   correctewaarden[11,11]=1
   correctewaarden[12,0]=1
   correctewaarden[12,1]=12
   correctewaarden[12,2]=66
   correctewaarden[12,3]=220
   correctewaarden[12,4]=495
   correctewaarden[12,5]=792
   correctewaarden[12,6]=924
   correctewaarden[12,7]=792
   correctewaarden[12,8]=495
   correctewaarden[12,9]=220
   correctewaarden[12,10]=66
   correctewaarden[12,11]=12
   correctewaarden[12,12]=1
   correctewaarden[13,0]=1
   correctewaarden[13,1]=13
   correctewaarden[13,2]=78
   correctewaarden[13,3]=286
   correctewaarden[13,4]=715
   correctewaarden[13,5]=1287
   correctewaarden[13,6]=1716
   correctewaarden[13,7]=1716
   correctewaarden[13,8]=1287
   correctewaarden[13,9]=715
   correctewaarden[13,10]=286
   correctewaarden[13,11]=78
   correctewaarden[13,12]=13
   correctewaarden[13,13]=1
   correctewaarden[14,0]=1
   correctewaarden[14,1]=14
   correctewaarden[14,2]=91
   correctewaarden[14,3]=364
   correctewaarden[14,4]=1001
   correctewaarden[14,5]=2002
   correctewaarden[14,6]=3003
   correctewaarden[14,7]=3432
   correctewaarden[14,8]=3003
   correctewaarden[14,9]=2002
   correctewaarden[14,10]=1001
   correctewaarden[14,11]=364
   correctewaarden[14,12]=91
   correctewaarden[14,13]=14
   correctewaarden[14,14]=1
   correctewaarden[15,0]=1
   correctewaarden[15,1]=15
   correctewaarden[15,2]=105
   correctewaarden[15,3]=455
   correctewaarden[15,4]=1365
   correctewaarden[15,5]=3003
   correctewaarden[15,6]=5005
   correctewaarden[15,7]=6435
   correctewaarden[15,8]=6435
   correctewaarden[15,9]=5005
   correctewaarden[15,10]=3003
   correctewaarden[15,11]=1365
   correctewaarden[15,12]=455
   correctewaarden[15,13]=105
   correctewaarden[15,14]=15
   correctewaarden[15,15]=1
   correctewaarden[16,0]=1
   correctewaarden[16,1]=16
   correctewaarden[16,2]=120
   correctewaarden[16,3]=560
   correctewaarden[16,4]=1820
   correctewaarden[16,5]=4368
   correctewaarden[16,6]=8008
   correctewaarden[16,7]=11440
   correctewaarden[16,8]=12870
   correctewaarden[16,9]=11440
   correctewaarden[16,10]=8008
   correctewaarden[16,11]=4368
   correctewaarden[16,12]=1820
   correctewaarden[16,13]=560
   correctewaarden[16,14]=120
   correctewaarden[16,15]=16
   correctewaarden[16,16]=1

   result=`./${PROG} $1 $2 1 | cut '-d=' -f2 | cut -'d ' -f2 `
   if [[ "$result" != ${correctewaarden[$1,$2]} ]]
   then
	   echo "Fout! De correcte waarde voor ${PROG}($1, $2) moet ${correctewaarden[$1,$2]} zijn, maar je programma geeft $result terug!"
  fi
}
correctnesscheck 0 0
correctnesscheck 1 0
correctnesscheck 2 1
correctnesscheck 4 2
correctnesscheck 8 3
correctnesscheck 16 4
correctnesscheck $n $k