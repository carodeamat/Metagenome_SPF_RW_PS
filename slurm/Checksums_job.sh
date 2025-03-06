#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=Checksums_job      # Job name
#SBATCH --output=%x_%j.out        # Output file for SLURM output
#SBATCH --time=01:00:00                 # Time limit
#SBATCH --cpus-per-task=16               # Number of cpus per task
#SBATCH --mem=4G                        # Memory per node
#SBATCH --nodes=1                       # Number of nodes

module load CCEnv
module load StdEnv/2023
module load gcc/12.3 r/4.3.1
# r-bundle-bioconductor includes stringr
module load r-bundle-bioconductor/3.18

MD5_CLUSTER="data/md5sums_cluster"
MD5_CORE="data/md5sums_core"

Rscript checksums.R $MD5_CLUSTER $MD5_CORE
