#!/bin/bash

# Get the directory. If empty, use current.
TARGET="${1:-.}"
OUTPUT_FILE="$(pwd)/output-packer.txt"

if [ ! -d "$TARGET" ]; then
    echo "Error: Directory '$TARGET' does not exist."
    exit 1
fi

# Convert TARGET to absolute path to ensure relative calculation works perfectly
TARGET_ABS=$(realpath "$TARGET")

echo "--- Starting ---"
echo "Reading: $TARGET_ABS"
echo "Output: $OUTPUT_FILE"
>"$OUTPUT_FILE"

find "$TARGET" -type f \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/build/*' \
    -not -name '.*' \
    -not -name 'package-lock.json' \
    -not -name 'output-packer.txt' \
    -not -name "$(basename "$0")" \
    -print0 | while IFS= read -r -d '' file; do

    # Calculate relative path
    RELATIVE_PATH=$(realpath --relative-to="$TARGET_ABS" "$file")

    # Debug: Show what is being processed on screen
    echo "Processing: $RELATIVE_PATH"

    # Robust check if it is a text file using 'file' command
    if file "$file" | grep -q "text"; then
        echo -e "\n\n==================================================" >>"$OUTPUT_FILE"
        echo "FILE: $RELATIVE_PATH" >>"$OUTPUT_FILE"
        echo "==================================================" >>"$OUTPUT_FILE"
        cat "$file" >>"$OUTPUT_FILE"
    else
        echo " -> Ignored (Binary): $RELATIVE_PATH"
    fi
done

echo "--- Done ---"
