import dendropy
import argparse

parser = argparse.ArgumentParser(prog="stitch_in_treetime",description="removes all the extra information that treetime gives")
parser.add_argument("input_treefile")
parser.add_argument("output_path")
parser.add_argument("output_schema")
parser.add_argument("--aggressive_filtering",action="store_true")

args = parser.parse_args()

t = dendropy.Tree.get(path=args.input_treefile,schema="nexus")
if args.aggressive_filtering:
    t.write(path=args.output_path,schema=args.output_schema,suppress_internal_node_labels=True,suppress_internal_taxon_labels=True)
else:
    t.write(path=args.output_path,schema=args.output_schema)

