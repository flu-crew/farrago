#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script takes a fasta file and a .txt file from BVBRC and combines them
to make a fasta file with a reasonable defline format
Created dy David E. Hufnagel on Jul 14, 2023

Last Updated by TN Aug. 23, 2024
- Changed how metadata was processed (csv file -> dataframe instead of array)
- Added gene segment from original def line to new def line
"""
import sys
import re
import pandas
from datetime import datetime

inpFasta = open(sys.argv[1])  #input fasta file
inpMeta = open(sys.argv[2])   #input tabular data file
out = open(sys.argv[3], "w")  #output fasta file



#Define functions
def SaveIntoDict(key, val, dictx):
    if key in dictx:
        dictx[key].append(val)
    else:
        dictx[key] = [val,]


def ReadFasta(fd): #Go through inp and store the file in a dict of key: defline   val: seq
    fastaDict = {}
    oldDef = ""; oldSeq = ""
    for line in fd:
        if line.startswith(">"):
            if oldSeq != "":
                SaveIntoDict(oldDef, oldSeq, fastaDict)
                oldDef = line.strip().strip(">")
                oldSeq = ""
            else:
                oldDef = line.strip().strip(">")
        else:
            oldSeq += line.strip()
    else:
        SaveIntoDict(oldDef, oldSeq, fastaDict)
        
    return(fastaDict)

segTable = {
    1: 'PB2',
    2: 'PB1',
    3: 'PA',
    4: 'HA',
    5: 'NP',
    6: 'NA',
    7: 'MP',
    8: 'NS'
}


###  BODY  ###
#Go through the CSV file and save metadata in a dict with the format key: ID  val: (strain, subtype, segment, host, location, date)
metaDict = {}

meta = pandas.read_csv(inpMeta)
# print(meta.info())

for ind, line in meta.iterrows():
    iD = str(line['Genome ID'])
    subtype = line['Subtype'].strip('"')
    strain = line['Strain'].replace("SWINE","Swine").replace("swine","Swine")\
        .replace("SW","Swine").replace(" ","_").strip('"')
    segment = segTable[line['Segment']]
    loc = strain.split('/')[2]
    date = pandas.to_datetime(line['Collection Date'].strip('"').strip()).date()

    #grabbing host info
    host = line['Host Name'].strip('"')
    if "scrofa" in host:
        host = 'swine'
        
    #Save metadata into dict (strain, subtype, segment, host, location, date)
    metaDict[iD] = (strain, subtype, segment, host, loc, date)
    # print(metaDict[iD])


#Go through the fasta file, create new deflines using the metada dict and print to output
inpDict = ReadFasta(inpFasta)
for defline, seqs in inpDict.items():
    if len(seqs) > 1:
        print("ERROR2!")
        sys.exit()
    else:
        seq = seqs[0]
        iD = defline.strip().split("|")[-1].strip("]").strip()
        if iD not in metaDict:
            iD += "0"
            if iD not in metaDict:
                iD = iD.strip("0")

        # ID  val: (strain, subtype, segment, host, loc, date)
        # Accension|strain_name|H5N1 (Type)|segement|clade|genotype|host-category|US-State|date
        # >|A/Swine/Iowa/18TOSU0355/2018|H1N2|PA|swine|Iowa|2018-06-07

        name = metaDict[iD][0]
        flutype = metaDict[iD][1]
        segment = metaDict[iD][2]
        host = metaDict[iD][3]
        loc = metaDict[iD][4]
        date = metaDict[iD][5]

        newDef = "%s|%s|%s|%s|%s|%s" % (name, flutype, segment, host, loc, date)
        newLines = ">%s\n%s\n" % (newDef, seq)       
        out.write(newLines)




inpFasta.close()
inpMeta.close()
out.close()