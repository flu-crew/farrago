#!/bin/python3
import re

# nameFile = open("Trees4Ram/ramtree_name.txt", "w")
nameFile = open("larger-subtree-mcc.txt", "w")

# with open("Trees4Ram/ramTemp.txt", "r") as file:
with open("larger-subtree-mcc.tre", "r") as file:
    for line in file.readlines():
        if("|" in line):
            list = re.findall(r"\|A/[\w/-]*\|", line)

    for name in list:
        if '|' in name:
            # nameFile.write(name.strip(":")+"\n")
            nameFile.write(name.strip("|")+"\n")
                
nameFile.close()