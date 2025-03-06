#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=fastqc_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=5:00:00
#SBATCH --ntasks=32
#SBATCH --mem=12G
#SBATCH --nodes=1

IN_DIR="data/fqfiles"
OUT_DIR="analysis"
LANE=$1

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
cd ..

module load CCEnv
module load StdEnv/2023
module load fastqc

ls $IN_DIR/*.fq | parallel -j $SLURM_NTASKS --joblog $OUT_DIR/log/fastqc.log fastqc -o $OUT_DIR/QC {}
ls $IN_DIR/*.fq | fastqc -o $OUT_DIR/QC -t $SLURM_NTASKS {}
