#!/bin/bash

VALGRIND=valgrind

get_nr_cycles() {
	if [ ! -e timing.out ]; then
		return 0
	fi

	# These fields match Ir, Dr, and Dw from the 'events: Ir I1mr ILmr Dr D1mr DLmr Dw D1mw DLmw ' line in the cachegrind output file
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

if [ "$1" -gt 21 ]; then
  printf "\033[0;33mFOUT!\033[0m <n> mag maximaal 21 zijn.\n"
  exit 1
fi

n=$1
iteraties=1000
if [ -n "$2" ]; then
	iteraties=$2
fi
PROG=pell-lucas

rm ./${PROG}
make pract02

if [ ! -e ./${PROG} ]
then
  printf "\033[0;33mFOUT!\033[0m Het assembleren van je code is gefaald.\n"
  exit 1
fi

$VALGRIND --tool=cachegrind --cache-sim=yes --cachegrind-out-file=timing.out ./${PROG} $n $iteraties &> output
if [ "$?" -ne 0 ]; then
  printf "\033[0;33mFOUT!\033[0m Het programma is gecrasht. Dit komt wellicht door een foute aanpassing. Bekijk eens de debug tips in de opgave.\n"
  exit 1
fi
cat output | grep $PROG 
get_nr_cycles
echo "Gesimuleerd: $total_cycles cycli"


echo # Empty line

correctnesscheck_output() {
   correctewaarden[0]=1
   correctewaarden[1]=1
   correctewaarden[2]=3
   correctewaarden[3]=7
   correctewaarden[4]=17
   correctewaarden[5]=41
   correctewaarden[6]=99
   correctewaarden[7]=239
   correctewaarden[8]=577
   correctewaarden[9]=1393
   correctewaarden[10]=3363
   correctewaarden[11]=8119
   correctewaarden[12]=19601
   correctewaarden[13]=47321
   correctewaarden[14]=114243
   correctewaarden[15]=275807
   correctewaarden[16]=665857
   correctewaarden[17]=1607521
   correctewaarden[18]=3880899
   correctewaarden[19]=9369319
   correctewaarden[20]=22619537
   correctewaarden[21]=54608393
   
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
	call pell_lucas
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
  echo "$replacement" "$(sed "s|^main:$|main2:|" pell-lucas.s)" > "$tmp_file.s"

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
