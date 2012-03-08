#!/bin/bash

if [[ ! $# == 1 ]]; then
	echo "Formaat: $0 aantal_iteraties"
	exit
fi

if [[ ! "`./pell 9 1 | awk '{print $3}'`"  = "985" ]]; then
	echo "De berekening is niet correct"
	exit
fi

./pell 9 $1

