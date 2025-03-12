output_file="common_tree_with_26_raxmlHPC_result_full.txt"  

> "$output_file"

for file in raxmlHPC_results/*.tree; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        base_name=$(echo "$filename" | cut -d'.' -f2)

        echo -e "$base_name\t$(cat "$file")" >> "$output_file"
    fi
done