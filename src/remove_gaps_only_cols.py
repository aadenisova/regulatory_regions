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

# Сохранение отфильтрованного выравнивания
with open(f"filtered_alignments/{gene_name}.aln", "w") as output_handle:
    AlignIO.write(
        MultipleSeqAlignment(filtered_alignment), output_handle, "clustal"
    )

print(','.join(species_to_save))