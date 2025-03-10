#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=BAM2fastq_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=02:00:00
#SBATCH --ntasks=32
#SBATCH --nodes=1

IN_DIR=data/FilteredBAM
OUT_DIR=data
LANE=$1

module load CCEnv
module load StdEnv/2023
module load gcc/12.3
module load samtools/1.20

cd $OUT_DIR
if [ ! -d "NoHost_fastq" ]; then
  mkdir NoHost_fastq/
fi
cd ..

cat $OUT_DIR/SampleIDs/sample_ids_"$LANE".txt | \
parallel -j $SLURM_NTASKS \
samtools fastq $IN_DIR/FiltHostSort_"$LANE"_{}.bam \
  -1 $OUT_DIR/NoHost_fastq/FiltHost_"$LANE"_"{}"_1.fastq.gz \
  -2 $OUT_DIR/NoHost_fastq/FiltHost_"$LANE"_"{}"_2.fastq.gz \
  -0 /dev/null -s /dev/null -n
