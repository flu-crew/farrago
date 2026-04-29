from Bio import SeqIO
import argparse
from datetime import datetime

parser = argparse.ArgumentParser(prog="restrict_seqs_by_date",description="restricts sequences in fasta file by given date cutoff")
parser.add_argument("filename")
parser.add_argument("lower_end")
parser.add_argument("higher_end")
parser.add_argument("output_file")
args = parser.parse_args()
records = SeqIO.parse(args.filename,"fasta")

start_year = float(args.lower_end)
end_year = float(args.higher_end)

filtered_sequences= []

valid_characters=set(["A","T","G","C","N","u","a","t","g","c","n"])

for record in records:
    alphabet = set(record.seq)
    if len(alphabet - valid_characters) > 0:
        continue
    name = record.name
    date_str = name.split("|")[-1]
    date = datetime.timetuple(datetime.strptime(date_str,"%Y-%m-%d"))
    dec_date = date.tm_year + (date.tm_yday/365)
    if start_year <= dec_date < end_year and "p" not in record.seq:
        filtered_sequences.append(record)
SeqIO.write(filtered_sequences,args.output_file,"fasta")
