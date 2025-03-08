#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=MapRef_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=24:00:00
#SBATCH --ntasks=8
#SBATCH --nodes=1

IN_DIR=data/fqfiles
OUT_DIR=data
REF_GENOME=/scratch/m/mallev/caro/Metagenome_SPF_RW_PS/RefGenomes/Mus_musculus/UCSC/mm10/Sequence/Bowtie2Index/
LANE=$1

module load CCEnv
module load StdEnv/2023
module load bowtie2/2.5.4

cd $OUT_DIR
if [ ! -d "MapRef" ]; then
  mkdir MapRef/
fi
cd ..

export BOWTIE2_INDEXES=$REF_GENOME

cat $OUT_DIR/SampleIDs/sample_ids_"$LANE".txt | \
parallel -j $SLURM_NTASKS \
bowtie2 -x genome \
    -1 $IN_DIR/*_"$LANE"_{}_1.fq.gz \
    -2 $IN_DIR/*_"$LANE"_{}_2.fq.gz \
    -S $OUT_DIR/MapRef/MapRef_"$LANE"_{}.sam
