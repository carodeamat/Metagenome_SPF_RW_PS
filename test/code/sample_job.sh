#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=fqsample
#SBATCH --output=test/%x_%j.out
#SBATCH --time=01:00:00
#SBATCH --ntasks=32
#SBATCH --nodes=1

# Load modules
module load CCEnv
module load StdEnv/2020
module load seqkit

# Define variables
IN_DIR=$1
OUT_DIR=$2
PROP=$3

# create output directory if it does not exist.
if [ ! -d $OUT_DIR ]; then
  mkdir $OUT_DIR/
fi
#Sample a proportion of the reads.
mkdir $SFQ_DIR
ls $IN_DIR/*_L01_*.fq.gz | parallel -j $SLURM_NTASKS \
    "seqkit sample -p $PROP -s 123 -o $OUT_DIR/{/} {}"
