#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=Gen_md5sum_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=00:15:00
#SBATCH --ntasks=32
#SBATCH --nodes=1

# Define argument
FQ_FILES=data/fqfiles

module load CCEnv
module load StdEnv/2023

# Create data log directory if they do not exist.
cd data
if [ ! -d "log" ]; then
  mkdir log/
fi
cd ../

# Run the md5sum calculation in parallel on all fastq files

# If a directory is provided as argument
if [ -d $FQ_FILES ]; then
  find $FQ_FILES -name "*.fq.gz" | \
  parallel -j $SLURM_NTASKS \
  --joblog data/log/gen_md5sums_log.log \
  bash src/gen_md5sums.sh {}

# Check if the argument is a text file (.txt extension)
elif [ -f $FQ_FILES ] && [[ $FQ_FILES == *.txt ]]; then
  cat $FQ_FILES | \
  parallel -j $SLURM_NTASKS \
  --joblog data/log/gen_md5sums_log.log \
  bash src/gen_md5sums.sh {}

# If it's neither
else
  echo "'$FQ_FILES' should be a directory or a text file with a list of existing fq files."
fi
