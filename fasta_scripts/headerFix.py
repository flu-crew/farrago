# input 1: fasta file to be cleaned
# input 2: csv metadata file
# input 3: new fasta

import sys

us_state_to_abbrev = {
    "Alabama": "AL",
    "Alaska": "AK",
    "Arizona": "AZ",
    "Arkansas": "AR",
    "California": "CA",
    "Colorado": "CO",
    "Connecticut": "CT",
    "Delaware": "DE",
    "Florida": "FL",
    "Georgia": "GA",
    "Hawaii": "HI",
    "Idaho": "ID",
    "Illinois": "IL",
    "Indiana": "IN",
    "Iowa": "IA",
    "Kansas": "KS",
    "Kentucky": "KY",
    "Louisiana": "LA",
    "Maine": "ME",
    "Maryland": "MD",
    "Massachusetts": "MA",
    "Michigan": "MI",
    "Minnesota": "MN",
    "Mississippi": "MS",
    "Missouri": "MO",
    "Montana": "MT",
    "Nebraska": "NE",
    "Nevada": "NV",
    "New Hampshire": "NH",
    "New Jersey": "NJ",
    "New Mexico": "NM",
    "New York": "NY",
    "North Carolina": "NC",
    "North Dakota": "ND",
    "Ohio": "OH",
    "Oklahoma": "OK",
    "Oregon": "OR",
    "Pennsylvania": "PA",
    "Rhode Island": "RI",
    "South Carolina": "SC",
    "South Dakota": "SD",
    "Tennessee": "TN",
    "Texas": "TX",
    "Utah": "UT",
    "Vermont": "VT",
    "Virginia": "VA",
    "Washington": "WA",
    "West Virginia": "WV",
    "Wisconsin": "WI",
    "Wyoming": "WY",
    "District of Columbia": "DC",
    "American Samoa": "AS",
    "Guam": "GU",
    "Northern Mariana Islands": "MP",
    "Puerto Rico": "PR",
    "United States Minor Outlying Islands": "UM",
    "U.S. Virgin Islands": "VI",
    "USA": "NK"
}
    
# invert the dictionary
abbrev_to_us_state = dict(map(reversed, us_state_to_abbrev.items()))


metadata = {}
with open(sys.argv[2], 'r') as metaFile:
    metaLines = metaFile.readlines()
    headerRow = True
    for entry in metaLines:
        row = entry.strip().split(",")
        name = row[1]
        date = row[0]
        genotype = row[6]
        state = abbrev_to_us_state[row[3].upper()] if len(row[3]) == 2 else "USA"
        
        if not headerRow:
            metadata[name] = dict({'date': date, 'state': state, 'genotype': genotype})
        else:
            headerRow = False

def fixHeader(line):
    header = ""
    data = line.split('|')
    # >|A/Chicken/USA/24-008355-003/2024|H5N1|HA|Chicken|USA|2024

    strain = data[1]
    fluType = data[2]
    segment = data[3]
    host = data[4]
    clade = ""
    
    name = strain.split("/")[3]

    if name in metadata.keys():
        genotype = metadata[name]["genotype"]
        date = metadata[name]["date"]
        state = metadata[name]["state"]
    else:
        return line
        
    # >|A/domestic_duck/Iowa/23-033840-003-original/2023|H5N1|HA|2.3.4.4b|B3.13|wildbird|Iowa|2023-11-02
    header = "|"+strain +"|"+fluType+"|"+segment+"|"+clade+"|"+genotype+"|"+host+"|"+state+"|"+date
    return header




seqList = {}
with open(sys.argv[1], 'r') as fastaFile:
    onSeq = False
    seq = ""
    fastaLines = fastaFile.readlines()

    for line in fastaLines:
        line = line.strip()
        if line in ['', '\n', '\r\n']:
            continue
        if line[0] == ">" and not onSeq:
            onSeq = True
            header = fixHeader(line[1:])

        elif line[0] == ">" and onSeq:
            seqList[header] = seq.upper()
            header = fixHeader(line[1:])
            seq = ""
    
        elif onSeq:
            # Storing sequence as string then appending to the string
            seq += line

    seqList[header] = seq.upper() # Add seq to dict

with open(sys.argv[3], 'w') as outFile:
    for header,seq in seqList.items():
        outFile.write(">"+header+'\n')
        outFile.write(seq+'\n')