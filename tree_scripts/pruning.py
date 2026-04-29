# input 1: tree to prune
# input 2: file of strains to remove
# input 3: output file

import dendropy
import sys



def get_strain_name_list(file_name: str) -> list[str]:
    list_handle = open(file_name)
    strain_list = [line.strip() for line in list_handle.readlines()]  # Remove '\n' from lines.
    list_handle.close()
    return strain_list

def filter_tree(tree_path: str, schema: str, filter_path: str, out_path: str, keep=True, full=False):
    filter_tokens = get_strain_name_list(filter_path)
    tree = dendropy.Tree.get(path=tree_path, schema=schema, preserve_underscores=True)
    assert isinstance(tree, dendropy.Tree)
    ending = '|' if full else ''
    filter_taxa = {taxon.label for taxon in tree.taxon_namespace if
                   any(taxon.label.count(prune_token + ending) > 0 for prune_token in filter_tokens)}
    if keep:
        prune_taxa = {taxon.label for taxon in tree.taxon_namespace}
        prune_taxa = prune_taxa.symmetric_difference(filter_taxa)
    else:
        prune_taxa = filter_taxa
    tree.prune_taxa_with_labels(prune_taxa)
    tree.write_to_path(out_path, schema=schema)


tree_path = sys.argv[1]
filter_path = sys.argv[2]
out_path = sys.argv[3]

schema = "nexus" if 'x' in tree_path else "newick"

filter_tree(tree_path, schema, filter_path, out_path, keep=False, full=False)