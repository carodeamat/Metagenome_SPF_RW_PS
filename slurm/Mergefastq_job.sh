#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=MergeLanes_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=05:00:00
#SBATCH --ntasks=32
#SBATCH --nodes=1

IN_DIR=data/NoHost_fastq
OUT_DIR=data

module load CCEnv
module load StdEnv/2023

cd $OUT_DIR
if [ ! -d "MergedLanes" ]; then
  mkdir MergedLanes/
fi
if [ ! -d "MergedReads" ]; then
  mkdir MergedReads/
fi
cd ..

cat $OUT_DIR/SampleIDs/sample_ids_L01.txt | \
parallel -j $SLURM_NTASKS \
cat $IN_DIR/FiltHost_L01_"{}"_1.fastq.gz \
  $IN_DIR/FiltHost_L02_"{}"_1.fastq.gz \
  $IN_DIR/FiltHost_L03_"{}"_1.fastq.gz \
  $IN_DIR/FiltHost_L04_"{}"_1.fastq.gz \
">" $OUT_DIR/MergedLanes/FiltMerged_"{}"_1.fastq.gz

cat $OUT_DIR/SampleIDs/sample_ids_L01.txt | \
parallel -j $SLURM_NTASKS \
cat $IN_DIR/FiltHost_L01_"{}"_2.fastq.gz \
  $IN_DIR/FiltHost_L02_"{}"_2.fastq.gz \
  $IN_DIR/FiltHost_L03_"{}"_2.fastq.gz \
  $IN_DIR/FiltHost_L04_"{}"_2.fastq.gz \
">" $OUT_DIR/MergedLanes/FiltMerged_"{}"_2.fastq.gz

cat $OUT_DIR/SampleIDs/sample_ids_L01.txt | \
parallel -j $SLURM_NTASKS \
cat $OUT_DIR/MergedLanes/FiltMerged_"{}"_1.fastq.gz \
  $OUT_DIR/MergedLanes/FiltMerged_"{}"_2.fastq.gz \
">" $OUT_DIR/MergedReads/Sample_"{}".fastq.gz

for i in $(cat $OUT_DIR/SampleIDs/sample_ids_L01.txt);
do
  echo $(zcat $OUT_DIR/MergedLanes/FiltMerged_${i}_1.fastq.gz|wc -l)/4|bc >> $OUT_DIR/MergedLanes/Read1_counts.txt
  echo $(zcat $OUT_DIR/MergedLanes/FiltMerged_${i}_2.fastq.gz|wc -l)/4|bc >> $OUT_DIR/MergedLanes/Read2_counts.txt
done
