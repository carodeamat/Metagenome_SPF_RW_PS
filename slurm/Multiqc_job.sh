#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=Multiqc_job
#SBATCH --output=%x_%j.out
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=4096M
#SBATCH --nodes=1

module load CCEnv
module load StdEnv/2023
module load python/3.12.4
module load scipy-stack/2024a

virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install --no-index multiqc

module load multiqc

IN_DIR="$1"
OUT_DIR="results"

cd $OUT_DIR
if [ ! -d "MultiQC" ]; then
  mkdir MultiQC/
fi
cd "$(pwd | sed "s|/$OUT_DIR||")"

multiqc $IN_DIR -o $OUT_DIR/MultiQC

deactivate
