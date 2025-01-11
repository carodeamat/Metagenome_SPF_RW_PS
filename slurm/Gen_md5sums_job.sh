#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=run_md5sum      # Job name
#SBATCH --output=%x_%j.out        # Output file for SLURM output
#SBATCH --time=01:00:00                 # Time limit
#SBATCH --ntasks-per-node=16               # Number of tasks per node
#SBATCH --mem=12G                        # Memory per node
#SBATCH --nodes=1                       # Number of nodes

# Define argument
FQ_FILES="$1"

# Run the md5sum calculation in parallel on all fastq files

# If a directory is provided as argument
if [ -d "$FQ_FILES" ]; then
  find $FQ_FILES -name "*.fq.gz" | \
  parallel -j $SLURM_TASKS_PER_NODE \
  --joblog ../log/gen_md5sums_log.log \
  bash src/gen_md5sums.sh {}

# Check if the argument is a text file (.txt extension)
elif [ -f "$FQ_FILES" ] && [[ "$FQ_FILES" == *.txt ]]; then
  cat $FQ_FILES | \
  parallel -j $SLURM_TASKS_PER_NODE \
  --joblog ../log/gen_md5sums_log.log \
  bash src/gen_md5sums.sh {}

# If it's neither
else
  echo "'$FQ_FILES' should be a directory or a text file with a list of existing fq files."
fi
