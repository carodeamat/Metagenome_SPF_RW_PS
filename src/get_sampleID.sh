#!/bin/bash

IN_DIR=$1
OUT_DIR=$2
LANE=$3

cd $OUT_DIR
if [ ! -d "SampleIDs" ]; then
  mkdir SampleIDs/
fi
cd ..

find $IN_DIR -name *_"$LANE"_*_1.fq.gz >> reads1.txt

#take only the sample number from the full file names and save it in a text file
for file in $(cat reads1.txt); do
  basefile=$(basename "$file" _1.fq.gz)
  filename=$(echo "$basefile" | cut -d '_' -f3)
  echo "$filename" >> $OUT_DIR/SampleIDs/sample_ids_$LANE.txt
done

rm reads1.txt

#sort sample numbers by order
sort -n $OUT_DIR/SampleIDs/sample_ids_$LANE.txt -o $OUT_DIR/SampleIDs/sample_ids_$LANE.txt
