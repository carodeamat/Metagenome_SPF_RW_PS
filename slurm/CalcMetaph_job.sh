#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=CalcMetaph_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=2:00:00
#SBATCH --ntasks=4
#SBATCH --nodes=1

IN_DIR=analysis/MetaphlanOut

module load CCEnv
module load StdEnv/2023
module load bowtie2/2.5.4
module load r
module load python/3.11.5

source $SCRATCH/humann_venv/bin/activate

merge_metaphlan_tables.py $IN_DIR/Sample_*_profile.txt > $IN_DIR/merged_abundance_table.txt

Rscript calculate_diversity.R --file="$IN_DIR/merged_abundance_table.txt" \
--out_directory="$IN_DIR" \
--diversity="beta" \
--metric="bray-curtis"
