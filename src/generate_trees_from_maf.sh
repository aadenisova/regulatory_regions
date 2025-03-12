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

    # Проверяем, существует ли файл
    if [ ! -f "maf_extracted/${gene}.maf" ]; then
        echo "maf_outputs/${seq_id}.maf"

        # Выполняем mafExtractor только если файла еще нет
        # mafExtractor
        mafExtractor --maf "maf_outputs/${seq_id}.maf" \
                    --seq "GCF_003957565.2_bTaeGut1.4.pri.${seq_id}" \
                    --start "${actual_start}" \
                    --stop "${end}" > "maf_extracted/${gene}.maf"
        echo "Ага, мы достали ген: $gene. Oн лежит в maf_extracted/${gene}.maf"
    else
        echo "Файл maf_extracted/${gene}.maf уже существует. Пропуск создания."
    fi

    if [ ! -f "fasta_extracted/${gene}.fa" ]; then
        echo "Обработка гена $gene"
        if python3 src/maf_to_fasta.py "$gene"; then
            # Скрипт выполнился успешно, продолжаем выполнение
            echo "Сконвертировали в fasta: $gene"
            # Здесь можно добавить дополнительные команды
        else
            # Скрипт завершился с ошибкой, пропускаем итерацию
            echo "Пропускаем ген $gene"
            continue
        fi
    else
        echo "fasta_extracted/${gene}.fa уже существует. Пропуск создания."
    fi
    
    if [ ! -f "clustalw2_alignment/${gene}.aln" ]; then
        # Выравнивание с ClustalW2
        clustalw2 -INFILE="fasta_extracted/${gene}.fa" \
                -OUTFILE="clustalw2_alignment/${gene}.aln" \
                -TYPE=DNA \
                -GAPOPEN=10 \
                -GAPEXT=0.1 \
                -PWGAPOPEN=10 \
                -PWGAPEXT=0.1 \
                -DNAMATRIX=IUB \
                -TOSSGAPS

        echo "Сделали выравнивание: $gene"
    else
        echo "clustalw2_alignment/${gene}.aln уже существует. Пропуск создания."
    fi

    mkdir -p trimed_alignment

    # export PATH="$PATH:/vggpfs/fs3/vgl/store/adenisova/programs/trimal/source/"
    trimal -in clustalw2_alignment/${gene}.aln -out trimed_alignment/${gene}.phy -phylip

    # if python3 src/remove_gaps_only_cols.py $gene; then
    #     # Скрипт выполнился успешно, продолжаем выполнение
    #     echo "Вторая обработка гена $gene"
    #     # Здесь можно добавить дополнительные команды
    # else
    #     # Скрипт завершился с ошибкой, пропускаем итерацию
    #     echo "Второй пропуск гена $gene"
    #     continue
    # fi


    # result_ids_to_save=$(python3 src/remove_gaps_only_cols.py $gene)
    # python3 src/adjast_tree.py $gene $result_ids_to_save

    # Построение дерева с raxmlHPC
    mkdir -p raxmlHPC_results
    # export PATH="$PATH:/vggpfs/fs3/vgl/store/adenisova/programs/standard-RAxML/"
    raxmlHPC -f e \
        -s trimed_alignment/${gene}.phy \
        -t shaohong_feng_for_most_common_species.tree \
        -n ${gene}.tree \
        -m GTRGAMMA \
        -o GCF_900496995.4,GCA_018139145.1

    mv RAxML_result.${gene}.tree raxmlHPC_results

    rm RAxML_rootedTree.${gene}.tree RAxML_log.${gene}.tree RAxML_binaryModelParameters.${gene}.tree RAxML_result.${gene}.tree RAxML_info.${gene}.tree

    echo "И даже построили дерево: $gene"

done

echo "Обработка завершена!"