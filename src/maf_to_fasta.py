from sys import argv
from ete3 import Tree
from Bio import AlignIO
from Bio.Align import MultipleSeqAlignment
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord


DIR_WITH_MAFS = "maf_extracted"
DIR_WITH_FASTA = "fasta_extracted"

gene_name = argv[1]

maf_file = f"{DIR_WITH_MAFS}/{gene_name}.maf"
fasta_file = f"{DIR_WITH_FASTA}/{gene_name}.fa"

# Читаем выравнивание из MAF
alignments = AlignIO.parse(maf_file, "maf")
record_dict = dict()

# species_must_df = pd.read_csv(
#     "common_species_with_innovation_rate.tsv",
#     sep = "\t"
# )
# species_must_be_in_alignment_set = set(species_must_df["Accesion"].tolist())
species_must_be_in_alignment_set = {"GCF_012460135.1","GCF_015832195.1","GCA_016904835.1","GCF_017639655.2","GCF_900496995.4","GCA_014839755.1","GCA_903797595.2","GCA_009819655.1","GCF_009829145.1","GCA_015220805.1","GCA_013407035.1","GCF_015227805.1","GCA_017639245.1","GCA_019023105.1","GCA_009764595.1","GCA_020746105.1","GCF_009650955.1","GCF_015220075.1","GCF_003957565.2","GCF_000738735.5","GCA_009819595.1","GCF_009819885.2","GCA_018139145.1","GCF_004027225.2","GCA_009769605.1","GCA_009819825.1"}
number_to_check = len(species_must_be_in_alignment_set)

for alignment in alignments:
    for record in alignment._records:
        name = '_'.join(record.name.split("_")[:2])
        # берём только нужные
        if name in species_must_be_in_alignment_set:
            sequence = record.seq._data.decode("utf-8")
            if name not in record_dict:
                record_dict[name] = sequence.strip('-')
            else:
                record_dict[name] += sequence
 

number_of_records = len(record_dict.keys())
# смотрим чтобы их было ровно X (or number_to_check)
if number_of_records < number_to_check:
    raise ValueError(f"Too small number of records (just {number_of_records})")
elif number_of_records > number_to_check:
    raise ValueError(f"I don't know how but you have more {number_of_records})")

file = open(fasta_file, "w")
for key in record_dict:
    file.write(f'>{key}\n{record_dict[key]}\n')