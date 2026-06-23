from Bio import SeqIO
import argparse
from collections import Counter
import re
START_CODON = "ATG"
STOP_CODON = ["TAA","TGA","TAG"]

def prune_to_cds(records):
    starts = Counter()
    ends = Counter()
    for record in records:
        start = record.seq.upper().find(START_CODON)
        end = max([record.seq.upper().rfind(sc) for sc in STOP_CODON])+4
        record.seq = record.seq[start:end]

if __name__=="__main__":
    parser = argparse.ArgumentParser(prog="H5N1 alignment construction")
    parser.add_argument("input_fasta")
    parser.add_argument("output_filtered_fasta")
    args = parser.parse_args()
    records = list(SeqIO.parse(args.input_fasta,"fasta"))
    filtered_records = []
    p =re.compile('[atgc]-{30,}[atgc]',re.IGNORECASE)
    for record in records:
        if p.search(str(record.seq)) is not None or record.seq.count("n")>len(record.seq)*0.3: # at most 30% of the sequence is unknown
            continue
        else:
            filtered_records.append(record)
    print(f"Outputting {len(filtered_records)} sequences")
    SeqIO.write(filtered_records,args.output_filtered_fasta,"fasta")
