# input 1: fasta file from IRMA
# input 2: name of output fasta file
# input 3: CSV file with IRMA metadata
# input 4 (optional): CSV file used for mugration analysis

import sys
import re

filename = sys.argv[1]
sample = filename.split(".")[0]
match = re.search(r'\d{4}-\d{2}-\d{2}', filename)
date = match.group()

# state = strain.split("_")[-1]
# host = strain.split("_")[2]

missing = ["TBD", "xx"]


with open(sys.argv[3], 'r') as metadata:
    lines = metadata.readlines()
    for line in lines:
        if sample in line:
            data = line.split(',')
            # date = data[1]
            host = data[7]
            strain = data[9]
            state = data[11]

            if data[13] in missing or "Minor" in data[13]:
                genotype = ""
            else:
                genotype = data[13]

            clade = ""
            fluType="H5N1"
                      
seqList={}

with open("IRMA-consensus-contigs/"+filename, 'r') as file:
    header = ""
    seq = ""
    onSeq = False
    lines = file.readlines()
    for line in lines:
        line = line.strip()
        if line in ['', '\n', '\r\n']:
            continue
        if line[0] == ">" and not onSeq:
            # Detected first seq header
            # Ideal header: Accension|strain_name|H5N1 (Type)|segement|clade|genotype|host-category|US-State|date
            # Current header: |strain_name|H5N1 (Type)|segement|clade|genotype|host-category|US-State|date
            onSeq = True
            segment = line[1:].split('_')[1]
            header = "|"+strain +"|"+fluType+"|" + segment + "|" +clade+"|"+genotype+"|"+host+"|"+ state + "|" + date

        elif line[0] == ">" and onSeq:
            seqList[header] = seq.upper() # Add seq to dict
            
            segment = line[1:].split('_')[1]
            header = "|"+strain +"|"+fluType+"|" + segment + "|" +clade+"|"+genotype+"|"+host+"|"+ state + "|" + date
            seq = ""

        elif onSeq:
            # Storing sequence as string then appending to the string
            seq += line

    seqList[header] = seq.upper() # Add seq to dict

# if len(sys.argv) > 4:
#     with open(sys.argv[2], 'a') as outFile, open(sys.argv[4], 'a') as csvFile:
#         #csvFile.write("name,date,host,location\n")
#         for header,seq in seqList.items():
#             outFile.write(">"+header+'\n')
#             outFile.write(seq+'\n')

#             csvFile.write(header+","+date+","+host+","+state+"\n")

# else:
with open(sys.argv[2], 'a') as outFile:
    for header,seq in seqList.items():
        outFile.write(">"+header+'\n')
        outFile.write(seq+'\n')