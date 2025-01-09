#!/bin/bash

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

  # Create directories if they do not exist.
  if [ ! -d "fqfiles" ]; then
    mkdir fqfiles/
  fi

  if [ ! -d "md5files" ]; then
    mkdir md5files/
  fi

  # If a file with list of fq files is not provided in the 4th argument,
  # then all the files from the URL provided will be downloaded
  if [ -z "$4" ]; then
    echo "downloading all .fq.gz and .fq.gz.md5sums files from url"


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
    awk -v base_url=$URLpath '{print base_url $0}' > fqfiles/fqurls.txt

    # First identify the .fq.gz.md5sums files in index
    # Then add the base url to each file.
    # Transfer all the file urls to a txt file.
    grep -oE 'href="[^"]+\.fq\.gz\.md5sums"' urls.html | \
    sed -E 's/href="([^"]+)"/\1/' | \
    awk -v base_url=$URLpath '{print base_url "/" $0}' > md5files/md5urls.txt

    # Remove the html index file
    rm urls.html

  elif [ -f "$fqFILES" ] && [[ "$fqFILES" == *.txt ]]; then

    # If the 4th argument with list of fq files is provided,
    # Then only those fq files and respective md5sums will be downloaded
    # in the respective directories
    echo "Downloading files provided in '$4'"


    # Delete fq files provided if they already exist
    xargs -a $4 -I {} bash -c '[ -f "{}" ] && rm {}'
    # Make URL paths for each fq file provided
    cat $4 | \
    awk -v base_url=$URLpath '{print base_url $0}' > fqfiles/fqurls.txt

    # Make URL paths for each fq file provided
    cat $4 | \
    awk -v base_url=$URLpath '{print base_url "/" $0 ".md5sums"}' > md5files/md5urls.txt

    # If the fourth argument is not a txt.file
  else
    echo "'$FQ_FILES' should be a text file with a list of fq files."
  fi

fi
