#!/bin/bash

# First argument: URL
URLpath="$1"

# Second argument: user
URLuser=$2

# Third argument: password
URLpw=$3

# Get a temporary index html file
wget --auth-no-challenge \
  --user=$URLuser \
  --password=$URLpw \
  -O urls.html \
  --continue \
  $URLpath

mkdir fqfiles
mkdir md5files

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
  awk -v base_url=$URLpath '{print base_url $0}' > md5files/md5urls.txt

# Remove the html index file
rm urls.html
