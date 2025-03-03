#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=fastqc_job
#SBATCH --output=%x_%j.out
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=8192M
#SBATCH --nodes=1

IN_DIR="$1"
OUT_DIR="results"

if [ ! -d $OUT_DIR ]; then
  mkdir $OUT_DIR/
fi
cd $OUT_DIR
if [ ! -d "QC" ]; then
  mkdir QC/
fi
if [ ! -d "log" ]; then
  mkdir log/
fi
cd "$(pwd | sed "s|/$OUT_DIR||")"

module load CCEnv
module load StdEnv/2023
module load fastqc

ls $IN_DIR/*.fq | parallel -j $SLURM_CPUS_PER_TASK --joblog $OUT_DIR/log/fastqc.log fastqc -o $OUT_DIR/QC {}
