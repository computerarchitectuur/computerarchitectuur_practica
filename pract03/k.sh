#!/bin/bash

rm -rf MyBoot.bin

nasm -f bin -o MyBoot.bin -l MyBoot.list scheduler.asm

