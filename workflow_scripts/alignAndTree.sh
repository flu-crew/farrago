#!/bin/bash

# Aligns and builds a ML tree (using IQTree) for all segments of a given file prefix

# $1 = file prefix

declare -a seg=("HA" "NA" "PB2" "PB1" "NS" "NP" "MP" "PA")

eval pref="$1"

for i in "${seg[@]}"
do
    smof grep "|${i}|" ${pref}.fasta > ${pref}_${i}.fasta
    if [ -e "${pref}_${i}.fasta" ]; then
        mkdir ${i}
        mv ${pref}_${i}.fasta ${i}
        cd ${i}
        mafft --thread -1 ${pref}_${i}.fasta > ${pref}_${i}.aln
        
        iqtree3 -T AUTO -s ${pref}_${i}.aln -m MFP -B 1000 --bnni --alrt 1000

        cd ..
    fi
done