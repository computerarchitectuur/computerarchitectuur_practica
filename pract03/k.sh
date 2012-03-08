#!/bin/bash
rm -f MyBoot.bin
nasm -f bin -o MyBoot.bin keyboard.asm
