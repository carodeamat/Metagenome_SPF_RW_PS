#!/bin/bash

# Check for number of arguments


# First argument: URL
URLpath=$1

# Second argument: user
URLuser=$2

# Third argument: password
URLpw=$3

#Fourth argument (optional: for selected files only)
fqFILES=$4


# Create directories if they do not exist.
cd data
if [ ! -d "fqfiles" ]; then
  mkdir fqfiles/
fi

if [ ! -d "md5files" ]; then
  mkdir md5files/
fi
cd ../
# If the 4th argument is "all",
# then URL paths will be generated for all the files of the URL provided
if [ "$fqFILES" = "all" ]; then

  # Get a temporary index html file
  wget --auth-no-challenge \
  --user=$URLuser \
  --password=$URLpw \
  -O urls.html \
  --continue \
  $URLpath

  # First identify the .fq.gz files in index
  # Then add the base url to each file.
  # Transfer all the file urls to a txt file.
  grep -oE 'href="[^"]+\.fq\.gz"' urls.html | \
  sed -E 's/href="([^"]+)"/\1/' | \
  awk -v base_url=$URLpath '{print base_url "/" $0}' > data/fqfiles/fqurls.txt

  # First identify the .fq.gz.md5sums files in index
  # Then add the base url to each file.
  # Transfer all the file urls to a txt file.
  grep -oE 'href="[^"]+\.fq\.gz\.md5sums"' urls.html | \
  sed -E 's/href="([^"]+)"/\1/' | \
  awk -v base_url=$URLpath '{print base_url "/" $0}' > data/md5files/md5urls.txt

  # Remove the html index file
  rm urls.html

# If the 4th argument with list of fq files is provided,
# Then only URLs for those fq files and respective md5sums will be
# generated in the respective directories

else

  # Make URL paths for each file provided
  cat $fqFILES | \
  awk -v base_url=$URLpath '{print base_url "/" $0}' > data/fqfiles/fqurls.txt

  # Make URL paths for md5sums of each file provided
  cat $fqFILES | \
  awk -v base_url=$URLpath '{print base_url "/" $0 ".md5sums"}' > data/md5files/md5urls.txt

fi
