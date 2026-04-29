#!/bin/bash

curr=$(pwd)

if [ -d "/tmp/genoflu" ]; then
  rm -rf /tmp/genoflu/
fi

mkdir /tmp/genoflu/

# arg 1 : fasta file
# arg 2: id list 

echo "Splitting fasta file..."

while IFS= read -r line; do
    smof grep $line $1 > /tmp/genoflu/$line.fasta
done < "$2"

cd /tmp/genoflu/

echo "Running genoflu"

for file in $(/bin/ls -d $PWD/*)
do
  echo $file
  genoflu.py -f $file
done

echo "Generating report..."

time=$(date '+%Y-%m-%d-%H_%M_%S')

for file in $(/bin/ls -d $PWD/* | grep tsv)
do
  head -1 $file >> $curr/genoflu-report-$time.tsv
  break
done

for file in $(/bin/ls -d $PWD/* | grep tsv)
do
  tail -1 $file >> $curr/genoflu-report-$time.tsv
done

rm -rf /tmp/genoflu
