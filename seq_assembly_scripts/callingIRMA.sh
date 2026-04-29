#!/bin/bash

# $1 - $n = sample ID
#   input format: 	23-011769-001-original_S130_L001

for i in "$@"
do
    IRMA FLU ${i}_R1.fastq.gz ${i}_R2.fastq.gz $i
done
