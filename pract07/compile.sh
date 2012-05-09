#!/bin/bash

rm *.class

javac -cp commons-cli-1.2.jar:. *.java

if [[ ! -e CacheSim.class ]];
then
   echo "compile error"
fi
