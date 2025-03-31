# Metagenome Analysis of gut microbiota from SPF RW PS mice
Metagenome analysis of fecal samples from mice maintained under SPF, pet store (PS), and rewilded (RW) conditions.

## Sample information
Fecal samples were obtained from mice cosidering different conditions.

### Colony
- SPF: Specific pathogen-free.
- PS: Pet store.
- RW: Rewilded.

### Sex
- Female
- Male

### Generation
- F1: first generation
- F2: second generation
- F3: third generation
- F4: fourth generation

## Sample processing
Total DNA was extracted from fecal samples using ....

## Sequencing

## Data processing
Data processing was performed in Niagara cluster form Alliance Canada. \
Scripts for slurm jobs are designed to run in Niagara. \
This includes downloading the files, checksums, QC, trimming, alignment, and taxonomic classification.

### Downloading files
Fastq files and md5sum files were downloaded from sever using the `download_files.sh` script.
The script takes 4 arguments:
1. URL
2. user
3. Password
4. Either a txt file with the list of specific fastq files or 'all' to download all the files in the URL provided.
```
bash download_files.sh <URLpath> <user> <password> all
```
The script creates a directory for fastq files and another directory for md5sums.

### Checksums
`Gen_md5sums_job.sh` is a slurm job script that generates md5sums from the downloaded fqfiles.
```
sbatch Gen_md5sums_job.sh
```
Then, the generated md5sums is compared to the md5sums provided by the core facility. \
As input `Checksums_job.sh` takes the directories containing md5sums files generated in the cluster ant the ones and from core facility.
```
sbatch Checksums_job.sh
```
The output will indicate if there are any incorrect or missing files. \
If there are failed files, it will generate a txt file with the name of those files, which can be used to download again with `download_files.sh`.

### QC
`fastqc_job.sh` is a slurm job script to run `fastq` for each fastq file. \
To speed up the process and resources allocation, the data to process is split by lane, which is specified as an argument for the script.
```
sbatch fastqc_job.sh L01
sbatch fastqc_job.sh L02
sbatch fastqc_job.sh L03
sbatch fastqc_job.sh L04
```
The output is saved in the analysis/QC directory. \
Then multiqc was run to generate a merged summary QC report.
```
sbatch Multiqc_job.sh
```

### Trimming
`trimmomatic` is used in the `Trim_job.sh` script to trim low quality sequences. \
The code reads the sample ID (number) from a txt file to recognize paired fastq reads for each sample and in each lane (argument).
```
sbatch Trim_job.sh L01
sbatch Trim_job.sh L02
sbatch Trim_job.sh L03
sbatch Trim_job.sh L04
```
Trimmed fastq files are saved in the Trimmed directory.

### Exclude host genome
To exclude sequences coming from mice (host), the files were first aligned to the mouse genome using `bowtie2` which generates SAM files.
```
sbatch MapRef_job.sh L01
sbatch MapRef_job.sh L02
sbatch MapRef_job.sh L03
sbatch MapRef_job.sh L04
```
Then, `samtools` is used to convert SAM to BAM, followed by filtering out mapped reads and sorting the bam files.
```
sbatch FilterHost_job.sh L01
sbatch FilterHost_job.sh L02
sbatch FilterHost_job.sh L03
sbatch FilterHost_job.sh L04
```
Finally, filtered and sorted bam files are converted to fastq files using `samtools`. \
Output fastq files are saved in the NoHost_fastq directory.
```
sbatch BAM2fastq_job.sh L01
sbatch BAM2fastq_job.sh L02
sbatch BAM2fastq_job.sh L03
sbatch BAM2fastq_job.sh L04
```

### Merge lanes and reads
The scrip `Mergefastq_job.sh` first merges fastq files coming from the same sample and same read number but different lanes, which output is saved in the MergedLanes directory. \
Then, it merges read 1 and read 2 from the respective samples and save the files in the MergedReads directory. \
```
sbatch Mergefastq_job.sh
```

### Alignment and classification
`metaphlan` was used to perform the alignment to the Chocophlan database. \
Then, it generates relative abundance tables for each sample.
```
sbatch Metaphlan_job.sh
```

### Calculations
The relative abundance tables were merged. \
Then, different diversity calculations were performed. \
The relative abundance table was also split by differnt taxonomic levels.
```
sbatch CalcMetaph_job.sh
```

### Data analysis and visualization
Output tables from metaphlan were used to perform PCoA calculations and plots in R.
The `Abundance_Anlysis.Rmd` file contains the workflow to perfom those analysis.
