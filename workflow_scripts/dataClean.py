# input 1: fasta file to be cleaned
# input 2: name of output fasta
# input 3: name of dupe file

import sys

seqList = {}
dupeList = {}

with open(sys.argv[1], 'r') as file:
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
            onSeq = True
            header = line[1:]
            # entry = header.split("|")

            # if (entry[0]+"+"+entry[3]) not in uniqList:
            #     uniqList.append(entry[0]+"+"+entry[3])

        elif line[0] == ">" and onSeq:
            # Detected new seq header
            if header not in seqList:
                seqList[header] = seq.upper() # Add seq to dict
            else:
                dupeList[header] = seq.upper()
            
            header = line[1:]
            seq = ""
            # entry = header.split("|")
            # if (entry[0]+"+"+entry[3]) not in uniqList:
            #     uniqList.append(entry[0]+"+"+entry[3])

        elif onSeq:
            # Storing sequence as string then appending to the string
            seq += line

    seqList[header] = seq.upper() # Add seq to dict

with open(sys.argv[2], 'w') as outFile:
    for header,seq in seqList.items():
        outFile.write(">"+header+'\n')
        outFile.write(seq+'\n')

with open(sys.argv[3], 'w') as outFile:
    for header,seq in dupeList.items():
        outFile.write(">"+header+'\n')
        outFile.write(seq+'\n')