#!/bin/bash

if [ $# -ne 4 ]; then
  echo -e "Error: Four arguments are required:\n1)URL\n2)user\n3)Password\n4)txt file with the list of fqfiles or 'all'"
  exit 1
fi

# First argument: URL
URLpath=$1

# Second argument: user
URLuser=$2

# Third argument: password
URLpw=$3

#Fourth argument: all or a txt file listing the fq file names to be downloaded.
fqFILES=$4

# If the 4th argument is all,
# then all the files from the URL provided will be downloaded
if [ $fqFILES = all ]; then
  echo "downloading all .fq.gz and .fq.gz.md5sums files from url"

# If the 4th argument is a txt file with a list of fq files,
# then only those files will be downloaded
elif [ -f $fqFILES ] && [[ $fqFILES == *.txt ]]; then

  # Delete fq and md5sums files if they already exist
  echo "Deleting pre-existing files if any"
  xargs -a $fqFILES -I {} bash -c '[ -f "data/fqfiles/{}" ] && rm data/fqfiles/{}'
  xargs -a $fqFILES -I {} bash -c '[ -f "data/md5sums_core/{}.md5sums" ] && rm data/md5sums_core/{}.md5sums'

  echo "Downloading files provided in '$fqFILES'"

# If the fourth argument is not a txt.file
else
  echo "'$fqFILES' should be either 'all' or a text file with a list of fq files."
  exit 1
fi


# getURLs.sh will generate txt files with lists of URLs and make directories
# for fq files and md5sums files.
# txt files will then be removed after download.
bash src/getURLs.sh $URLpath $URLuser $URLpw $fqFILES

# Download md5sums files in parallel and save in md5files/
cd data/md5sums_core/
cat md5urls.txt | parallel -j 8 --joblog download_md5files.log \
wget --auth-no-challenge \
--user=$URLuser \
--password=$URLpw \
--no-parent \
--no-host-directories \
--cut-dirs=4 \
--continue \
"{}"

rm md5urls.txt
echo "md5sums files were saved in the md5sums_core/ directory"
echo "Number of files in md5sums_core/ directory:"
ls -1 | wc -l

# Download fq files in parallel and save in fqfiles/
cd ../fqfiles/
cat fqurls.txt | parallel -j 8 --joblog download_fqfiles.log \
wget --auth-no-challenge \
--user=$URLuser \
--password=$URLpw \
--no-parent \
--no-host-directories \
--cut-dirs=4 \
--continue \
"{}"

rm fqurls.txt
echo "fq files were saved in the fqfiles/ directory"
echo "Number of files in fqfiles/ directory:"
ls -1 | wc -l

cd ../..
