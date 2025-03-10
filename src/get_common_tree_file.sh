output_file="common_tree.txt"  

> "$output_file"

for file in filtered_alignments/*.treefile; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        base_name=$(echo "$filename" | cut -d'.' -f1)

        echo -e "$base_name\t$(cat "$file")" >> "$output_file"
    fi
done