#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=MapRef_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=02:00:00
#SBATCH --ntasks=8
#SBATCH --nodes=1

IN_DIR=data/fqfiles
OUT_DIR=data/MapRef
REF_GENOME=/scratch/m/mallev/caro/Metagenome_SPF_RW_PS/RefGenomes/Mus_musculus/UCSC/mm10/Sequence/Bowtie2Index/
LANE=$1

module load CCEnv
module load StdEnv/2023
module load bowtie2/2.5.4

if [ ! -d $OUT_DIR ]; then
  mkdir $OUT_DIR/
fi

export BOWTIE2_INDEXES=$REF_GENOME

if [ ! -f $OUT_DIR/sample_ids_$LANE.txt ]; then
  bash src/get_sampleID.sh $IN_DIR $OUT_DIR $LANE
fi
#remove the last two rows that correlate to the positive/negative control samples
sed -i '$d' $OUT_DIR/sample_ids_$LANE.txt
sed -i '$d' $OUT_DIR/sample_ids_$LANE.txt

cat $OUT_DIR/sample_ids_$LANE.txt | \
parallel -j $SLURM_NTASKS \
bowtie2 -x genome \
    -1 $IN_DIR/*_$LANE_{}_1.fq.gz \
    -2 $IN_DIR/*_$LANE_{}_2.fq.gz \
    -S $OUT_DIR/MapRef_$LANE_{}.sam
/scratch/m/mallev/caro/Metagenome_SPF_RW_PS/RefGenomes/Mus_musculus/UCSC/mm10/Sequence/Bowtie2Index/
