import argparse

"""
Splits a nexus file with named trees into individual newick files. 
"""


parser = argparse.ArgumentParser(name="nexus_splitter")
parser.add_argument("nexus_file")

args = parser.parse_args()

with open(args.nexus_file,"r") as nexus:
    for line in nexus:
        if line.startswith("#"):
            continue
        elif line.strip().startswith("tree"):
            fields = line.split()
            filename = f"{fields[1]}.tre"
            with open(filename,"w") as treefile:
                treefile.write(fields[-1])
