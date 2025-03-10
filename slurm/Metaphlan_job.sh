#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=Metaphlan_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=10:00:00
#SBATCH --ntasks=2
#SBATCH --nodes=1

IN_DIR=data/MergedReads
OUT_DIR=analysis
BATCH="$1"

module load CCEnv
module load StdEnv/2023
module load bowtie2/2.5.4
module load python/3.11.5
module load samtools

source $SCRATCH/humann_venv/bin/activate

cd $OUT_DIR
if [ ! -d "MetaphlanOut" ]; then
  mkdir MetaphlanOut/
fi
if [ ! -d "BowtieOut" ]; then
  mkdir BowtieOut/
fi
if [ ! -d "VSCout" ]; then
  mkdir VSCout/
fi
cd ..

cat data/SampleIDs/sample_batch_$BATCH.txt | \
parallel -j $SLURM_NTASKS \
metaphlan $IN_DIR/Sample_"{}".fastq.gz \
--input_type fastq \
-1 $IN_DIR/../MergedLanes/FiltMerged_"{}"_1.fastq.gz \
-2 $IN_DIR/../MergedLanes/FiltMerged_"{}"_2.fastq.gz \
--mpa3 \
--add_viruses \
--profile_vsc \
--vsc_out $OUT_DIR/VSCout/Sample_"{}"_vsc.txt \
--bowtie2out $OUT_DIR/BowtieOut/Sample_"{}"_bowtie.txt \
--offline \
-o $OUT_DIR/MetaphlanOut/Sample_"{}"_profile.txt

deactivate
