from sys import argv
from Bio.Align import MultipleSeqAlignment
from Bio import AlignIO

# Загрузка выравнивания в формате .aln
gene_name = argv[1]

alignment = AlignIO.read(f"clustalw2_alignment/{gene_name}.aln", "clustal")

n_species = len(alignment[:, 0])

cols_to_delete = [
     i for i in range(alignment.get_alignment_length()) 
     if sum(seq[i] == '-' for seq in alignment) >= n_species - 2
]

n_deleted_cols = 0
for col in cols_to_delete:
    col -= n_deleted_cols 
    alignment = alignment[:, :col] + alignment[:, col+1:]
    n_deleted_cols += 1

alignment_len_part = alignment.get_alignment_length()*0.8
american_flamingo = "GCA_009819775.1"
maguari_stork = "GCA_017639555.1"
theristicus_caerulescens = "GCA_020745775.1"

species_to_delete = []
species_to_save = []
for species in range(n_species):
    if (len([i for i in alignment[species,:] if i == '-']) > alignment_len_part) or alignment[species,:].id in [american_flamingo, maguari_stork, theristicus_caerulescens]:
        species_to_delete.append(alignment[species,:].id)
    else:
        species_to_save.append(alignment[species,:].id)

filtered_alignment = [record for record in alignment if record.id not in species_to_delete]

species_must_be_in_alignment_set = {"GCF_012460135.1","GCF_015832195.1","GCA_016904835.1","GCF_017639655.2","GCF_900496995.4","GCA_014839755.1","GCA_903797595.2","GCA_009819655.1","GCF_009829145.1","GCA_015220805.1","GCA_013407035.1","GCF_015227805.1","GCA_017639245.1","GCA_019023105.1","GCA_009764595.1","GCA_020746105.1","GCF_009650955.1","GCF_015220075.1","GCF_003957565.2","GCF_000738735.5","GCA_009819595.1","GCF_009819885.2","GCA_018139145.1","GCF_004027225.2","GCA_009769605.1","GCA_009819825.1"}
number_to_check = len(species_must_be_in_alignment_set)

if len(species_to_save) < number_to_check:
    raise ValueError(f"Too small number of records (just {number_of_records})")

# Сохранение отфильтрованного выравнивания
with open(f"filtered_alignments/{gene_name}.aln", "w") as output_handle:
    AlignIO.write(
        MultipleSeqAlignment(filtered_alignment), output_handle, "clustal"
    )

print(','.join(species_to_save))