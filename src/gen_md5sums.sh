#!/bin/bash
# gen_md5sums.sh
# Script to generate md5sums from a file provided as argument.

# Get the input file from argument
IN_FILE="$1"

# Generate the output file name, ending in md5sums.txt
OUT_FILE=$(basename -- ${IN_FILE%.fq.gz}.md5sums)

cd data
if [ ! -d "md5sums_cluster" ]; then
  mkdir md5sums_cluster/
fi
cd ../

# Run the md5sum command and save the output to the corresponding file
md5sum $IN_FILE > data/md5sums_cluster/$OUT_FILE

echo "md5sums generated for '$IN_FILE'"
