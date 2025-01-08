#!/bin/bash
# gen_md5sums.sh
# Script to generate md5sums from a file provided as argument.

# Get the input file from argument
input_file="$1"

# Generate the output file name, ending in md5sums.txt
output_file=$(basename -- ${input_file%.fq.gz}.md5sums.txt)

# Run the md5sum command and save the output to the corresponding file
md5sum "$input_file" > "$output_file"
