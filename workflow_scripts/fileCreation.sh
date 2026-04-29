#!/bin/bash

# This script has various ways to split up a fasta file.

######################################################################################

# Makes a new fasta file with sequences designated by the inputs
# $1 = input file
# $2 = output file
# $3-n = list of strains

# smof grep $3 $1 > $2
# for i in "${@:4}"
# do
#     echo -ne "Working on ${i}\r"
#     smof grep $i $1 >> $2
# done

######################################################################################

# Makes new fasta files for each segment given a single input fasta and the prefix for the new files
# $1 = input fasta file
# $2 = output file prefix

# array of influenza segments
declare -a seg=("HA" "NA" "NS" "NP" "MP" "PA" "PB2" "PB1")
eval pref="$2"

## now loop through the above array
for i in "${seg[@]}"
do
    printf '\r%s Processing: %s' "$(tput el)" "${pref}_${i}"
    smof grep "|${i}|" $1 >> ${pref}_${i}.fasta
done

######################################################################################

# Makes new fasta files for each segment from an existing fasta file and several IRMA files
# $1 = input gisaid fasta folder
# $2 - input IRMA fasta 
# $3 = file with list of strains
# $4 = output file prefix

# ## array of influenza segments
# declare -a seg=("HA" "NA" "NS" "NP" "MP" "PA" "PB2" "PB1")
# eval pref="$4"

# ## now loop through the above array
# for i in "${seg[@]}"
# do
#     ## grab relevant strains from gisaid file
#     smof grep -f $3 $1/h5n1${i}.fasta >> ${pref}_${i}.fasta

#     ## grab specific segment from IRMA file
#     smof grep "|${i}|" $2 >> ${pref}_${i}.fasta
# done
