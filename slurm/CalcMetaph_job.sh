#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=CalcMetaph_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=2:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1

IN_DIR=analysis

module load CCEnv
module load StdEnv/2023
module load bowtie2/2.5.4
module load r
module load python/3.11.5

source $SCRATCH/humann_venv/bin/activate

merge_metaphlan_tables.py $IN_DIR/MetaphlanOut/Sample_*_profile.txt > $IN_DIR/MetaphlanOut/merged_abundance_table.txt
merge_vsc_tables.py $IN_DIR/VSCout/Sample_*_vsc.txt > $IN_DIR/VSCout/merged_abundance_table.txt

Rscript calculate_diversity.R --file="$IN_DIR/MetaphlanOut/merged_abundance_table.txt" \
--out_directory="$IN_DIR/MetaphlanOut" \
--diversity="beta" \
--metric="bray-curtis"
