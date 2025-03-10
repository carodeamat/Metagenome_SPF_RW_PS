#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=FilterHost_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=02:00:00
#SBATCH --ntasks=32
#SBATCH --nodes=1

IN_DIR=data/MapRef
OUT_DIR=data
LANE=$1

module load CCEnv
module load StdEnv/2023
module load gcc/12.3
module load samtools/1.20

cat $OUT_DIR/SampleIDs/sample_ids_"$LANE".txt | \
parallel -j $SLURM_NTASKS \
samtools view -bS -o $IN_DIR/MapRef_"$LANE"_{}.bam $IN_DIR/MapRef_"$LANE"_{}.sam


cd $OUT_DIR
if [ ! -d "FilteredBAM" ]; then
  mkdir FilteredBAM/
fi
cd ..

cat $OUT_DIR/SampleIDs/sample_ids_"$LANE".txt | \
parallel -j $SLURM_NTASKS \
samtools view -b -f 12 -F 256 \
  -o $OUT_DIR/FilteredBAM/FiltHost_"$LANE"_{}.bam \
  $IN_DIR/MapRef_"$LANE"_{}.bam

cat $OUT_DIR/SampleIDs/sample_ids_"$LANE".txt | \
parallel -j $SLURM_NTASKS \
samtools sort -n -m 5G \
  $OUT_DIR/FilteredBAM/FiltHost_"$LANE"_{}.bam -o $OUT_DIR/FilteredBAM/FiltHostSort_"$LANE"_{}.bam

rm -f $OUT_DIR/FilteredBAM/FiltHost_"$LANE"_*.bam
