#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=Checksums_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1

module load CCEnv
module load StdEnv/2023
module load gcc/12.3 r/4.3.1
# r-bundle-bioconductor includes stringr
module load r-bundle-bioconductor/3.18

MD5_CLUSTER="data/md5sums_cluster"
MD5_CORE="data/md5sums_core"

Rscript src/checksums.R $MD5_CLUSTER $MD5_CORE
