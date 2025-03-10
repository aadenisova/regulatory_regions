from sys import argv
from ete3 import Tree

gene_name = argv[1]
ids_to_save = argv[2].split(",")

PATH = "/lustre/fs5/vgl/store/adenisova/Inno/upstreams/"
tree_from_file = open(f"{PATH}/shaohong_feng_truncated.tree", "r").read()
tree = Tree(tree_from_file)

print(tree)

tree.prune(ids_to_save)

print(tree)

cactus_file_to_save = open(f"{PATH}/master_trees/{gene_name}_shaohong_feng.tree", "w")
cactus_file_to_save.write(tree.write())
cactus_file_to_save.close()
