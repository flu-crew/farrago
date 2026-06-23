segments=(PA PB1 PB2 NA MP NS NP  HA)

echo "Cleaning alignment"
for i in "${segments[@]}"; do 
    prefix=${i}_sequence_restricted.fasta
    sed -i $prefix.cds.aln -e "s/['()]/_/g" 
    sed -i $prefix.cds.aln -e "s/[][]/_/g" 
    sed -i $prefix.dates.csv -e "s/['()]/_/g"
    sed -i $prefix.dates.csv -e "s/[][]/_/g"
done

# NOTE: If activating below script, rememeber to change the values in find_common_sequences as well
#echo "Removing sequences below 25th quantile"
#tempdir=$(mktemp -d)
#trap 'rm -rf "$tempdir";' EXIT
#for i in "${segments[@]}"; do
#    prefix=${i}_sequence_restricted.fasta
#    smof clean -x $prefix.cds.aln > "$tempdir/$prefix.cds.raw"
#    cutoff=$(smof stat "$tempdir/$prefix.cds.raw" | grep "5sum" | sed "s/  //g" | cut -d " " -f 3)
#    echo "Cutoff length: $cutoff"
#    smof stat "$tempdir/$prefix.cds.raw" 
#    smof filter -l $cutoff "$tempdir/$prefix.cds.raw" > $prefix.cds.raw  
#    cat $prefix.cds.raw | grep ">" > "$tempdir/cleaned_seqs"
#    cat $prefix.cds.aln | grep ">" > "$tempdir/old_seqs"
#    diff "$tempdir/cleaned_seqs" "$tempdir/old_seqs" > ${i}_removed_sequences
#    echo "Removed $(wc -l ${i}_removed_sequences) $i sequences"
#done
echo "Finding common sequences"
../find_common_sequences.sh PA_sequence_restricted.fasta.cds.aln PB1_sequence_restricted.fasta.cds.aln PB2_sequence_restricted.fasta.cds.aln NA_sequence_restricted.fasta.cds.aln MP_sequence_restricted.fasta.cds.aln NS_sequence_restricted.fasta.cds.aln NP_sequence_restricted.fasta.cds.aln HA_sequence_restricted.fasta.cds.aln

echo "Realigning sequences"
for i in "${segments[@]}"; do 
    prefix=${i}_sequence_restricted.fasta
    mafft --thread 16 $prefix.cds.aln.truncated > $prefix.cleantrunc.aln
done
