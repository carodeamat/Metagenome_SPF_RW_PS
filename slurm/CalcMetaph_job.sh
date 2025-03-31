#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=CalcMetaph_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=2:00:00
#SBATCH --ntasks=1
#SBATCH --nodes=1

IN_DIR=analysis/MetaphlanOut

module load CCEnv
module load StdEnv/2023
module load bowtie2/2.5.4
module load r
module load python/3.11.5

source $SCRATCH/humann_venv/bin/activate

merge_metaphlan_tables.py $IN_DIR/Sample_*_profile.txt > $IN_DIR/merged_abundance_table.txt
merge_vsc_tables.py $IN_DIR/Sample_*_vsc.txt > $IN_DIR/merged_abundance_table_vsc.txt

Rscript calculate_diversity.R --file="$IN_DIR/merged_abundance_table.txt" \
--out_directory="$IN_DIR" \
--diversity="beta" \
--metric="bray-curtis"

Rscript calculate_diversity.R --file="$IN_DIR/merged_abundance_table.txt" \
--out_directory="$IN_DIR" \
--diversity="alpha" \
--metric="shannon"

Rscript calculate_diversity.R --file="$IN_DIR/merged_abundance_table.txt" \
--out_directory="$IN_DIR" \
--diversity="alpha" \
--metric="simpson"

grep -E "s__|Sample" $IN_DIR/merged_abundance_table.txt \
| grep -v "t__" \
| sed "s/^.*|//g" \
> $IN_DIR/merged_abundance_table_species.txt

grep -E "g__|Sample" $IN_DIR/merged_abundance_table.txt \
| grep -v "s__" \
| sed "s/^.*|//g" \
> $IN_DIR/merged_abundance_table_genus.txt

grep -E "f__|Sample" $IN_DIR/merged_abundance_table.txt \
| grep -v "g__" \
| sed "s/^.*|//g" \
> $IN_DIR/merged_abundance_table_family.txt

grep -E "c__|Sample" $IN_DIR/merged_abundance_table.txt \
| grep -v "o__" \
| sed "s/^.*|//g" \
> $IN_DIR/merged_abundance_table_class.txt

grep -E "p__|Sample" $IN_DIR/merged_abundance_table.txt \
| grep -v "c__" \
| sed "s/^.*|//g" \
> $IN_DIR/merged_abundance_table_phylum.txt
