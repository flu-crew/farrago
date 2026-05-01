# Takes in a set of fasta files and truncates them down to the common sequences in them all
# By default a file i.fasta will be truncated as i.fasta.truncated

tempdir = $(mktemp -d)
trap 'rm -rf "$tempdir"; exit' ERR EXIT
filelist="$@"

for file in "${filelist[@]}"; do
    echo "Gathering sequences from $file"
    sed -n "/>/p" $file | sed -e "s/^>//g" > $tempdir/${file}_sequences
done

cat $tempdir/$1_sequences > $tempdir/common_sequences
echo "Finding subset"
for file in "${filelist[@]}"; do
    comm -12 $tempdir/common_sequences $file | sort > $tempdir/temporary_file
    cat $tempdir/temporary_file > $tempdir/common_sequences
done

echo "Found $(wc -l $tempdir/common_sequences) common headers"

for file in "${filelist[@]}"; do
    smof grep -f $tempdir/common_sequences $file > $file.truncated
done
