#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=run_analyze
#SBATCH --output=test/%x_%j.out
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=32
#SBATCH --mem=12G
#SBATCH --nodes=1

# Load modules
module load CCEnv
module load StdEnv/2020
module load seqkit
cd $SCRATCH

# Define variables
IN_DIR=$1
OUT_DIR=$2
PROP=$3

#Sample a proportion of the reads.
mkdir $SFQ_DIR
ls $IN_DIR/*.fq.gz | parallel -j $SLURM_CPUS_PER_TASK \
    "seqkit sample -p $PROP -s 123 -o $OUT_DIR/{/} {}"
