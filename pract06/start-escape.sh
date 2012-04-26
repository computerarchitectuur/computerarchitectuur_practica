#!/bin/bash

if [ ! -f $HOME/pract05/Escape ]; then
  cp $HOME/pract06/Escape $HOME/pract05/
fi

export LD_LIBRARY_PATH=$HOME/pract05:.

./Escape
