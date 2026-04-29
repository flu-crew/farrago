
#!/usr/bin/env python3

import ete4
import argparse
from cluster_affinity import rooted_cluster_affinity,calculate_rooted_tau

def minus_method(t,leaf_list):
    t1 = t.copy()
    t1.prune(leaf_list)
    return t1

def calculate_cluster_affinity(current_tree,tlist):
    current_leaf_set = set([i.name for i in current_tree.leaves()])
    tlist_leaves = dict([(t,[i.name for i in t.leaves() if i.name in current_leaf_set]) for t in tlist])
    restricted_tree_pairs = [(minus_method(t,tlist_leaves[t]),minus_method(current_tree,tlist_leaves[t])) for t in tlist]
    current_dist = sum([(rooted_cluster_affinity(pair[0],pair[1])/calculate_rooted_tau(pair[0])) for pair in restricted_tree_pairs])
    return current_dist

def calculate_rf_cost(current_tree,tlist):
    current_leaf_set = set([i.name for i in current_tree.leaves()])
    tlist_leaves = dict([(t,[i.name for i in t.leaves() if i.name in current_leaf_set]) for t in tlist])
    restricted_tree_pairs = [(minus_method(t,tlist_leaves[t]),minus_method(current_tree,tlist_leaves[t])) for t in tlist]
    current_dist = sum([pair[0].robinson_foulds(pair[1])[0]/(2*len(list(pair[0].leaves()))-4) for pair in restricted_tree_pairs])
    return current_dist

if __name__ == "__main__":
   parser = argparse.ArgumentParser(prog="calc_tree_distances",description="Compares two trees (or sets of trees) and returns the normalied RF and ACA cost")
   parser.add_argument("compared_tree")
   parser.add_argument("supertree")
   args = parser.parse_args()
   supertree = ete4.Tree(args.supertree)
   total_ca = 0
   total_rf = 0
   with open(args.compared_tree,"r") as file:
       tlist = [ete4.Tree(l.strip()) for l in file if l.strip()]
       final_rf  = calculate_rf_cost(supertree,tlist)
       final_dist = calculate_cluster_affinity(supertree,tlist)
   print(f"{final_rf},{final_rf/len(tlist)},{final_dist},{final_dist/len(tlist)}")

