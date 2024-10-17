#!/bin/zsh

jobs -p > >(perl -lne '/\s(\d+)\s/ and system "kill -9 $1"')
