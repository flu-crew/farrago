from Bio import SeqIO
import argparse
from datetime import datetime

parser = argparse.ArgumentParser(prog="date_extractor",description="Extracts dates for treetime given a fasta file, assuming that dates are the last column")
parser.add_argument("filename")
parser.add_argument("output_file_name")

args = parser.parse_args()

records = SeqIO.parse(args.filename,"fasta")

with open(args.output_file_name,"w+") as date_file:
    date_file.write("name,date,dec_date\n")
    for record in records:
        name = record.name
        date_str = name.split("|")[-1]
        date = datetime.timetuple(datetime.strptime(date_str,"%Y-%m-%d"))
        dec_date = date.tm_year + (date.tm_yday/365)
        date_file.write(f"{name},{date_str},{dec_date}\n")
