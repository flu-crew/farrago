declare -a seg=("HA" "NA" "NS" "NP" "MP" "PA" "PB2" "PB1")

## now loop through the above array
for i in "${seg[@]}"
do
    echo -ne "Working on ${i} time tree\r"
    python pruning.py ${i}/treetime/timetree.nexus treeRemove.txt ${i}/treetime/timetree-trimmed.nexus

    echo

    echo -ne "Working on ${i} treetime_host_mugration\r"
    python pruning.py ${i}/treetime_host_mugration/annotated_tree.nexus treeRemove.txt ${i}/treetime_host_mugration/annotated_tree-trimmed.nexus

    echo

    echo -ne "Working on ${i} treetime_loc_mugration\r"
    python pruning.py ${i}/treetime_loc_mugration/annotated_tree.nexus treeRemove.txt ${i}/treetime_loc_mugration/annotated_tree-trimmed.nexus

    echo

    echo -ne "Working on ${i} treetime_clock\r"
    python pruning.py ${i}/treetime_clock/rerooted.newick treeRemove.txt ${i}/treetime_clock/rerooted-trimmed.newick

    echo

    # echo -ne "Working on IQTree ${i}\r"
    # smot grep -f keep.txt ${i}/2344b-postTempest_${i}.aln.treefile > ${i}/2344b-postTempest_${i}-trimmed.treefile
  
done

