#!/bin/bash
#SBATCH --job-name=batch_processing   # Название задачи
#SBATCH --output=logs/batch_%A_%a.out     # Файл вывода (для каждого задания)
#SBATCH --error=logs/batch_%A_%a.err      # Файл ошибок (для каждого задания)
#SBATCH --array=0-160                  # Диапазон задач (настроить под количество батчей)
#SBATCH --ntasks=1                   # Количество задач на одну задачу массива
#SBATCH --mail-user=savouriess2112@gmail.com

# # Разбиваем файл на батчи по X строк (без заголовка)
# input_file=GCF_003957565.2_2k_upstream.bed 
# lines_per_batch=100
# header=$(head -n 1 "$input_file") # Сохраняем заголовок

# # Разделяем файл (без заголовка) на части
# tail -n +2 "$input_file" | split -l "$lines_per_batch" - "batch_"

# # Добавляем заголовок обратно в каждый батч
# for file in batch_*; do
#     echo "$header" | cat - "$file" > temp && mv temp "$file"
# done

# Получаем список всех файлов-батчей
batches=($(ls batch_*))
batch_file=${batches[$SLURM_ARRAY_TASK_ID]} # Выбираем файл для текущего задания

# Запускаем обработку этого батча
./src/generate_trees_from_maf.sh "$batch_file"
