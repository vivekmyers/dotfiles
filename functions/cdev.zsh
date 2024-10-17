#!/bin/zsh

CUDA_VISIBLE_DEVICES=$(shell nvidia-smi -L | cut -c5 | shuf | head -n1) bash -c
