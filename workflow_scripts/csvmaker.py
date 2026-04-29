# Ideal header: Accension|strain_name|H5N1 (Type)|segement|clade|genotype|host-category|US-State|date

stateFile = open("meta.csv", "w")
stateFile.write("name,accension,strain_name,type,segement,clade,genotype,host-category,US-State,date\n")

with open("deflines.txt", "r") as file:
    for line in file.readlines():
        data = line.strip('>').split('|')
        
        header = line[1:]
        dnaAcc = data[0]
        strain = data[1]
        fluType=data[2]
        segment = data[3]
        clade = data[4]
        genotype = data[5]
        host = data[6]
        state = data[7]
        date = data[-1].strip()

        header = dnaAcc+"|"+strain +"|"+fluType+"|" +segment+"|" +clade+"|"+genotype+"|"+host+"|"+state+"|"+date

        stateFile.write(header+","+dnaAcc+","+strain +","+fluType+","+segment+","+clade+","+genotype+","+host+","+state+","+date+"\n")

stateFile.close()