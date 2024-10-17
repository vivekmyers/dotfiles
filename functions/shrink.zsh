#!/bin/zsh


for i in "$@"; do
    convert "$i" -resize 500 "${i%.*}_small.jpg"
done
