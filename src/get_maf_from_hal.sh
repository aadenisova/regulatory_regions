#!/bin/bash

#SBATCH --job-name=hal2maf_conversion  # Название задания
#SBATCH --output=logs/hal2maf_conversion_%x_%j.out       # Файл для вывода (название_задания_ID.out)
#SBATCH --error=logs/hal2maf_conversion_%x_%j.err        # Файл для ошибок (название_задания_ID.err)
#SBATCH --cpus-per-task=4              # Количество CPU на задачу

# Путь к файлу HAL
HAL_FILE="/vggpfs/fs3/vgl/store/adenisova/data/alignment/vgp_birds_60way/vgp_birds_60way.hal"

# Геном и параметры для команды hal2maf
REF_GENOME="GCF_003957565.2_bTaeGut1.4.pri"

# Файл с хромосомами
CHROMOSOME_FILE="chromosomes.tsv"

# Директория для вывода MAF-файлов
OUTPUT_DIR="maf_outputs"
mkdir -p $OUTPUT_DIR

# Чтение хромосом из файла и запуск hal2maf для каждой хромосомы
while IFS=$'\t' read -r CHROMOSOME; do
    echo "Запуск hal2maf для хромосомы: $CHROMOSOME"
    
    OUTPUT_MAF="${OUTPUT_DIR}/${CHROMOSOME}.maf"
    
    srun hal2maf --noAncestors --noDupes --onlyOrthologs \
        --refGenome $REF_GENOME \
        --refSequence $CHROMOSOME \
        $HAL_FILE $OUTPUT_MAF &
done < <(tail -n +2 $CHROMOSOME_FILE)  # Пропускаем заголовок файла

wait  # Ожидание завершения всех задач
echo "Все задачи завершены."