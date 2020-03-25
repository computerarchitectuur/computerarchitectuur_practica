#!/bin/bash

rm -rf MyBoot.bin MyBoot.list MyBoot.map

nasm -f bin -o MyBoot.bin -l MyBoot.list scheduler.asm

