#!/bin/bash

# First argument: URL
URLpath=$1

# Second argument: user
URLuser=$2

# Third argument: password
URLpw=$3

#Fourth argument (optional: for selected files only)
fqFILES=$4

  # If a file with list of fq files is not provided in the 4th argument,
  # then all the files from the URL provided will be downloaded
if [ -z "$4" ]; then
  echo "downloading all .fq.gz and .fq.gz.md5sums files from url"

else
  echo "Downloading files provided in '$4'"

fi

# getURLs.sh will generate txt files with lists of URLs and make directories
# for fq files and md5sums files.
# txt files will then be removed after download.
getURLs.sh $URLpath $URLuser $URLpw $fqFILES

# Download md5sums files in parallel and save in md5files/
cd md5files/
cat md5urls.txt | parallel -j 8 --joblog results/log/download_md5files.log \
wget --auth-no-challenge \
--user=URLuser \
--password=URLpw \
--no-parent \
--no-host-directories \
--cut-dirs=4 \
--continue \
"{}"

rm md5urls.txt
echo "md5sums files were saved in the md5files/ directory"
echo "Number of files in md5files/ directory:"
ls -1 | wc -l

# Download fq files in parallel and save in fqfiles/
cd fqfiles/
cat fqurls.txt | parallel -j 8 --joblog results/log/download_fqfiles.log \
wget --auth-no-challenge \
--user=URLuser \
--password=URLpw \
--no-parent \
--no-host-directories \
--cut-dirs=4 \
--continue \
"{}"

rm fqurls.txt
echo "fq files were saved in the fqfiles/ directory"
echo "Number of files in fqfiles/ directory:"
ls -1 | wc -l
