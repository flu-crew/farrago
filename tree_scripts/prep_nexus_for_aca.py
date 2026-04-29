import ete4
from ete4 import nexus
import argparse

parser = argparse.ArgumentParser(prog="ca_matrix_prep",description="Given a nexus file ensures that the trees are valid for ACA")
parser.add_argument("input_nexus")
parser.add_argument("output_nexus")
parser.add_argument("--threshold",type=float)

def resolve_multifurcations(t,threshold):
    for v in t.traverse("postorder"):
        if not v.is_leaf and "dist" in v.props and v.props["dist"] <= threshold:
            v.delete()

args = parser.parse_args()

fstring = """#NEXUS
begin trees;
"""
with open(args.input_nexus,"r") as f:
    t = nexus.load(f)
    common_leaf_set = None
    print("Finding common leaf set")
    for k in t:
        if common_leaf_set is None:
            common_leaf_set = set(t[k].leaf_names())
        else:
            common_leaf_set = common_leaf_set.intersection(t[k].leaf_names())
    for k in t:
        print("Pruning tree to common leaves")
        t[k].prune(common_leaf_set)
        print(f"Removing nodes with support less than {args.threshold}")
        resolve_multifurcations(t[k],args.threshold)
        fstring += f"tree {k} = {t[k].write()}\n"
fstring += "end;"
with open(args.output_nexus,"w") as outfile:
    outfile.write(fstring)

