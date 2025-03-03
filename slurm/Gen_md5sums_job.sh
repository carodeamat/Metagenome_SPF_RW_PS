#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=Gen_md5sum_job      # Job name
#SBATCH --output=%x_%j.out        # Output file for SLURM output
#SBATCH --time=01:00:00                 # Time limit
#SBATCH --cpus-per-task=16               # Number of cpus per task
#SBATCH --mem=12G                        # Memory per node
#SBATCH --nodes=1                       # Number of nodes

# Define argument
FQ_FILES="$1"

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
  parallel -j $SLURM_CPUS_PER_TASK \
  --joblog data/log/gen_md5sums_log.log \
  bash src/gen_md5sums.sh {}

# Check if the argument is a text file (.txt extension)
elif [ -f $FQ_FILES ] && [[ $FQ_FILES == *.txt ]]; then
  cat $FQ_FILES | \
  parallel -j $SLURM_CPUS_PER_TASK \
  --joblog data/log/gen_md5sums_log.log \
  bash src/gen_md5sums.sh {}

# If it's neither
else
  echo "'$FQ_FILES' should be a directory or a text file with a list of existing fq files."
fi

sacct -j $SLURM_JOB_ID --format=JobID%16,Submit,Start,Elapsed,NCPUS,CPUTime,ReqMem,ExitCode,NodeList%8
