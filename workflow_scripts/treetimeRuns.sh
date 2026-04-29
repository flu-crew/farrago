#!/bin/bash

# array of influenza segments
declare -a seg=("HA" "NA" "PB2" "PB1" "MP" "PA" "NS" "NP")

## now loop through the above array
for i in "${seg[@]}"
do

    # # echo -ne "Working on ${i} treetime\r"
    # if [[ "$i" != "NS" && "$i" != "NP" ]]; then
    # # this command doesn't work for NS and NP when there is a short time window
        treetime --tree ${i}/study_${i}.aln.treefile --aln ${i}/study_${i}.aln --dates meta.csv --confidence --max-iter 30 --covariation --clock-filter 5 --outdir ${i}/treetime

    # else
    # # use this for NS and NP
    #     treetime --tree ${i}/study_${i}.aln.treefile --aln ${i}/study_${i}.aln --dates meta.csv --confidence --max-iter 30 --covariation --clock-filter 0 --outdir ${i}/treetime
    # fi


    # echo -ne "Working on ${i} loc mugration\r"
    # treetime mugration --tree ${i}/treetime/timetree.nexus --states meta.csv --attribute US-State --confidence --outdir ${i}/treetime_loc_mugration
    treetime mugration --tree ${i}/study_${i}.aln.treefile --states meta.csv --attribute US-State --confidence --outdir ${i}/treetime_loc_mugration
    
    # echo -ne "Working on ${i} host mugration\r"
    # treetime mugration --tree ${i}/treetime/timetree.nexus --states meta.csv --attribute host-category --confidence --outdir ${i}/treetime_host_mugration
    treetime mugration --tree ${i}/study_${i}.aln.treefile --states meta.csv --attribute host-category --confidence --outdir ${i}/treetime_host_mugration

    # echo -ne "Working on ${i} treetime clock\r"
    # treetime clock --tree ${i}/study_${i}.aln.treefile --aln ${i}/study_${i}.aln --dates meta.csv --covariation --outdir ${i}/treetime_clock
    treetime clock --tree ${i}/study_${i}.aln.treefile --aln ${i}/study_${i}.aln --dates meta.csv --covariation --outdir ${i}/treetime_clock


    

done
