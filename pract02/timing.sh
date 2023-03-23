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
  echo "Gebruik van dit script: $0 <n>" >&2
  exit 1
fi

if [ "$1" -gt 21 ]
then
  echo "<n> mag maximaal 21 zijn" >&2
  exit 1
fi

n=$1
iteraties=1000
if [ -n "$2" ]; then
	iteraties=$2
fi
PROG=telephone

rm ./${PROG}
make pract02

if [ ! -e ./${PROG} ]
then
  echo "Er was een FOUT bij het assembleren van je ${PROG}.s!"
  exit
fi

$VALGRIND --tool=cachegrind --cachegrind-out-file=timing.out ./${PROG} $n $iteraties &> output
cat output | grep Telephone 
get_nr_cycles
echo "Gesimuleerd: $total_cycles cycli"


echo # Empty line

correctnesscheck_output() {
   correctewaarden[0]=1
   correctewaarden[1]=1
   correctewaarden[2]=2
   correctewaarden[3]=4
   correctewaarden[4]=10
   correctewaarden[5]=26
   correctewaarden[6]=76
   correctewaarden[7]=232
   correctewaarden[8]=764
   correctewaarden[9]=2620
   correctewaarden[10]=9496
   correctewaarden[11]=35696
   correctewaarden[12]=140152
   correctewaarden[13]=568504
   correctewaarden[14]=2390480
   correctewaarden[15]=10349536
   correctewaarden[16]=46206736
   correctewaarden[17]=211799312
   correctewaarden[18]=997313824
   correctewaarden[19]=514734144
   correctewaarden[20]=2283827616
   correctewaarden[21]=3988575904

   
   i=$n
   result=`./${PROG} $i 1 | cut '-d=' -f2 | cut -'d ' -f2 `
   if [[ "$result" != ${correctewaarden[$i]} ]]
   then
	   printf "\033[0;33mFOUT!\033[0m De correcte waarde voor ${PROG}($i) moet ${correctewaarden[$i]} zijn, maar je programma geeft $result terug!\n"
  fi
}

join_by() { local IFS="$1"; shift; echo "$*"; }

replacement=$(cat << EOM
main:
	endbr32
	leal 4(%esp), %ecx
	andl \$-16, %esp
	pushl -4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	pushl %ecx

	subl \$128, %esp /* guard against partial stack overwrite */

	movl %esp, __sp_prior
	movl %ebp, __bp_prior
	movl \$0x2f645177, %ebx
	movl \$0x34773957, %esi
	movl \$0x67586351, %edi

	pushl \$4
	call telephone
	addl \$4, %esp

	xorl %eax, %eax
.check_sp:
	cmpl __sp_prior, %esp
	jz .check_bp
	orl \$1, %eax
.check_bp:
	cmpl __bp_prior, %ebp
	jz .check_ebx
	orl \$2, %eax
.check_ebx:
	cmpl \$0x2f645177, %ebx
	jz .check_esi
	orl \$4, %eax
.check_esi:
	cmpl \$0x34773957, %esi
	jz .check_edi
	orl \$8, %eax
.check_edi:
	cmpl \$0x67586351, %edi
	jz .check_done
	orl \$16, %eax
.check_done:
	movl __sp_prior, %esp
	movl __bp_prior, %ebp
	movl -4(%ebp), %ecx
	leave
	leal -4(%ecx), %esp
	ret
.data
	__sp_prior: .long 0
	__bp_prior: .long 0
.text
/* */
EOM
)

correctnesscheck_callingconvention() {
  tmp_file=$(mktemp || exit 1)
  trap 'rm -f -- "$tmp_file"' EXIT
  echo "$replacement" "$(sed "s|^main:$|main2:|" telephone.s)" > "$tmp_file.s"
  
  gcc -fno-pie -no-pie -m32 "$tmp_file.s" -o "$tmp_file"_bin &> /dev/null
  
  if [ $? -ne 0 ]
  then
    echo "Kon de oproepconventie niet controleren" >&2
    exit 1
  fi

  "$tmp_file"_bin &> /dev/null
  result=$?
  if [ $result -ne 0 ]
  then
    wrong=()
    if [ $(($result & 1)) -eq 1 ]
    then
      wrong=("${wrong[@]}" "esp")
    fi
    if [ $(($result & 2)) -eq 2 ]
    then
      wrong=("${wrong[@]}" "ebp")
    fi
    if [ $(($result & 4)) -eq 4 ]
    then
      wrong=("${wrong[@]}" "ebx")
    fi
    if [ $(($result & 8)) -eq 8 ]
    then
      wrong=("${wrong[@]}" "esi")
    fi
    if [ $(($result & 16)) -eq 16 ]
    then
      wrong=("${wrong[@]}" "edi")
    fi
    printf "\033[0;33mFOUT!\033[0m De oproepconventie is geschonden, volgende registers worden overschreven en niet teruggezet op hun oorspronkelijke waarde: %s\n" $(join_by , "${wrong[@]}")
  fi
}

correctnesscheck_output
correctnesscheck_callingconvention
