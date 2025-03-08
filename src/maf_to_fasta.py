from sys import argv
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

for alignment in alignments:
    if len(alignment._records) < 6:
        #print(alignment._records)
        continue
    for record in alignment._records:
        name = '.'.join(record.name.split(".")[:-2])
        sequence = record.seq._data.decode("utf-8")
        if name not in record_dict:
            record_dict[name] = sequence.strip('-')
        else:
            record_dict[name] += sequence

file = open(fasta_file, "w")
for key in record_dict:
    file.write(f'>{key}\n{record_dict[key]}\n')

# seqs = []
# for key in record_dict:
#     seqs.append(SeqRecord(Seq(record_dict[key]), id=key))

# alignment = MultipleSeqAlignment(seqs)
# print(alignment)
# for key in record_dict:
#     print(f'>{record_dict[key].name}\n{record_dict[key].seq}')

# Записываем выравнивание в FASTA
# with open(fasta_file, "w") as f:

# # Записываем выравнивание в FASTA
# with open(fasta_file, "w") as f:
#     for alignment in alignments:
#         print(alignment._records)
#         print(alignment._records[0].id)
#         AlignIO.write(alignment, f, "fasta")