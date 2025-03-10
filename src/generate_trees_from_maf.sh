#!/bin/bash

# Убедитесь, что файл с данными передан как аргумент
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <input_file>"
    exit 1
fi

input_file=$1

# Создаем необходимые директории, если они не существуют
mkdir -p maf_extracted fasta_extracted clustalw2_alignment

# Читаем файл построчно, пропуская заголовок
tail -n +2 "$input_file" | while read -r line; do
    # Извлекаем значения из строки
    seq_id=$(echo "$line" | awk '{print $1}')
    start=$(echo "$line" | awk '{print $2}')
    end=$(echo "$line" | awk '{print $3}')
    gene=$(echo "$line" | awk '{print $4}')

    # Вычисляем actual_start
    actual_start=$(($end - 5000))
    echo "start: $actual_start end: $end"

    # Проверяем, чтобы actual_start не был меньше 0
    if [ "$actual_start" -lt 0 ]; then
        actual_start=0
    fi

    # Выполняем команды для текущей строки
    echo "Обрабатываем ген: $gene"
    echo "maf_outputs/${seq_id}.maf"

    # mafExtractor
    mafExtractor --maf "maf_outputs/${seq_id}.maf" \
                --seq "GCF_003957565.2_bTaeGut1.4.pri.${seq_id}" \
                --start "${actual_start}" \
                --stop "${end}" > "maf_extracted/${gene}.maf"

    echo "Ага, мы достали ген: $gene. Oн лежит в maf_extracted/${gene}.maf"
    # Конвертация в FASTA
    if python3 src/maf_to_fasta.py "$gene"; then
        # Скрипт выполнился успешно, продолжаем выполнение
        echo "Обработка гена $gene"
        # Здесь можно добавить дополнительные команды
    else
        # Скрипт завершился с ошибкой, пропускаем итерацию
        echo "Пропускаем ген $gene"
        continue
    fi

    echo "Сконвертировали в fasta: $gene"
    
    # Выравнивание с ClustalW2
    clustalw2 -INFILE="fasta_extracted/${gene}.fa" \
              -OUTORDER=clustalw2_alignment \
              -OUTFILE="clustalw2_alignment/${gene}.aln" \
              -TYPE=DNA \
              -GAPOPEN=10 \
              -GAPEXT=0.1 \
              -PWGAPOPEN=10 \
              -PWGAPEXT=0.1 \
              -DNAMATRIX=IUB \
              -TOSSGAPS

    echo "Сделали выравнивание: $gene"

    result_ids_to_save=$(python3 src/remove_gaps_only_cols.py $gene)
    python3 src/adjast_tree.py $gene $result_ids_to_save

    # Построение дерева с IQ-TREE
    iqtree -s "filtered_alignments/${gene}.aln" \
           -t "master_trees/${gene}_shaohong_feng.tree" \
           -redo

    echo "И даже построили дерево: $gene"

done

echo "Обработка завершена!"