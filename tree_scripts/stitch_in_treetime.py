import dendropy
import argparse

parser = argparse.ArgumentParser(prog="stitch_in_treetime",description="removes all the extra information that treetime gives")
parser.add_argument("input_treefile")
parser.add_argument("output_path")
parser.add_argument("output_schema")

args = parser.parse_args()

t = dendropy.Tree.get(path=args.input_treefile,schema="nexus")
t.write(path=args.output_path,schema=args.output_schema)

