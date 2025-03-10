from sys import argv
from ete3 import Tree

PATH = "/lustre/fs5/vgl/store/adenisova/Inno/upstreams/"
tree_from_file = open(f"{PATH}/master_trees/LOC115495916_cactus_tree.tree", "r").read()
tree = Tree(tree_from_file)

print(tree)