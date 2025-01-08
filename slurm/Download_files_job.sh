#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=download_files      # Job name
#SBATCH --output=download_files.log    # Log file for SLURM output
#SBATCH --time=01:00:00                 # Time limit
#SBATCH --cpus-per-task=8               # Number of CPUs per task
#SBATCH --mem=4G                        # Memory per node
#SBATCH --nodes=1                       # Number of nodes

# Check for number of arguments
if [ $# -lt 3 ] || [ $# -gt 4 ]; then
  echo -e "Three arguments are required: \n 1) URL \n 2) user \n 3) Password"
  echo "The fourth argument (list of fq files urls) is optional."
  exit 1

else
  # First argument: URL
  URLpath=$1

  # Second argument: user
  URLuser=$2

  # Third argument: password
  URLpw=$3

  #Fourth argument (optional: for selected files only)
  fqFILES=$4

  # If a file with URLs for fq files is not provided in the 4th argument,
  # then all the files from the URL provided will be downloaded
  if [ -z "$4" ]; then
    echo "downloading all .fq.gz and .fq.gz.md5sums files from url"

    # getURLs.sh will generate txt files with lists of URLs and make directories
    # for fq files and md5sums files.
    # txt files will then be removed after download.
    getURLs.sh $URLpath $URLuser $URLpw

    # Download md5sums files in parallel and save in md5files/
    cd md5files/
    cat md5urls.txt | parallel -j $SLURM_CPUS_PER_TASK --joblog download_files.log bash \
    wget --auth-no-challenge \
    --user=URLuser \
    --password=URLpw \
    --no-parent \
    --no-host-directories \
    --cut-dirs=4 \
    --continue \
    {}
    rm md5urls.txt
    echo "md5sums files were saved in the md5files/ directory"
    echo "Number of files in md5files/ directory:"
    ls -1 | wc -l

    # Download fq files in parallel and save in fqfiles/
    cd fqfiles/
    cat fqurls.txt | parallel -j $SLURM_CPUS_PER_TASK --joblog download_files.log bash \
    wget --auth-no-challenge \
    --user=URLuser \
    --password=URLpw \
    --no-parent \
    --no-host-directories \
    --cut-dirs=4 \
    --continue \
    {}

    rm fqurls.txt
    echo "fq files were saved in the fqfiles/ directory"
    echo "Number of files in fqfiles/ directory:"
    ls -1 | wc -l

  else

    # If the 4th argument with list of URLs is provided,
    # Then only those fq files will be downloaded
    # in a pre-existing fqfiles/ directory
    echo "Downloading files provided in '$4'"

    if [ ! -d "fqfiles" ]; then
      mkdir fqfiles/
    fi

    cd fqfiles/
    cat $4 | parallel -j $SLURM_CPUS_PER_TASK --joblog download_files.log bash \
    wget --auth-no-challenge \
    --user=URLuser \
    --password=URLpw \
    --no-parent \
    --no-host-directories \
    --cut-dirs=4 \
    --continue \
    {}
    echo "Indicated fq files were saved in the fqfiles/ directory"
    echo "Number of files in fqfiles/ directory:"
    ls -1 | wc -l
  fi

cd ../

fi
