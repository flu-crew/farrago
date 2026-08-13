segments=(PA PB1 PB2 HA NA MP NS NP  )
echo "Splitting seqs by date cutoff"

mkdir cutoff_$1_$2

for i in "${segments[@]}"; do 
    echo $i
    cutoff_filename=cutoff_$1_$2/${i}_sequence_restricted.fasta
    python restrict_seqs_date.py ${i}_sequence.fasta $1 $2 $cutoff_filename
    python sort_sequences.py $cutoff_filename $cutoff_filename.dates.csv
    mafft --thread 16 $cutoff_filename > $cutoff_filename.aln
    cat $cutoff_filename.aln | smof subseq -b $(python process_values.py $cutoff_filename.aln) > $cutoff_filename.cds.aln
    iqtree3 -s $cutoff_filename.cds.aln -T 16 -m GTR+F+I+I+R2
done

