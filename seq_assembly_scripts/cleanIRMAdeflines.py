# input 1: fasta file to be cleaned
# input 2: IRMA metadata csv
# input 3: new csv metadata file

import sys
import pandas
import datetime

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
    "USA": "NK",
}
    
# invert the dictionary
abbrev_to_us_state = dict(map(reversed, us_state_to_abbrev.items()))

wildBirds = ['WILD-BIRD', 'GOOSE', '_AH', 'HAWK', 'PIGEON', 'GRACKLE']
poultry = ['CHICKEN', 'TURKEY', 'DUCK', 'POULTRY', 'PEACOCK', 'POOLED']
domesticMammals = ['DOMESTIC', 'GOAT', '_CAT', 'ALPACA']
mammals = ['SKUNK', 'FOX', 'RACCOON', 'MOUSE', 'LION', 'BOBCAT']

metadata = pandas.read_csv(sys.argv[2])
stateFile = open(sys.argv[3], "w")
stateFile.write("name,barcode,segement,genotype,host-category,US-State,date\n")


def fixHeader(line):
    header = ""
    data = line.split('|')

    row = metadata[metadata['metadata-white-poultry-or-mammal---yellow-wb'].isin([data[0]])]

    if row.empty:
        return line

    date = row['Date seq'].to_string().split()[1]
    date = datetime.datetime.strptime(date, "%m/%d/%Y").strftime("%Y-%m-%d")
    
    state = row['State'].to_string().split()[1]
    state = abbrev_to_us_state[state.upper()] if len(state) == 2 else 'USA'
    
    
    if 'CATTLE' in data[0].upper():
        host = 'cattle'
    elif any(map(data[0].upper().__contains__, wildBirds)):
        host = 'wild-bird'
    elif any(map(data[0].upper().__contains__, poultry)):
        host = 'poultry'
    elif any(map(data[0].upper().__contains__, domesticMammals)):
        host = 'domestic-mammal'
    elif any(map(data[0].upper().__contains__, mammals)):
        host = 'mammal'
    else:
        host = 'NNNNNNNN'


    genotype = row['Consensus genotype'].to_string().split()[1]
    segment = data[1]
    barcode = row['File'].to_string().split()[1]

    header = f'{barcode}|{genotype}|{segment}|{date}'
    stateFile.write(header+","+barcode+","+segment+","+","+genotype+","+host+","+state+","+date+"\n")

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

with open(sys.argv[1], 'w') as outFile:
    for header,seq in seqList.items():
        outFile.write(">"+header+'\n')
        outFile.write(seq+'\n')

stateFile.close()