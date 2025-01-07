#!/bin/bash

# First argument: URL
URLpath="$1"

# Second argument: user
URLuser=$2

# Third argument: password
URLpw=$3

# Get the URL paths for each file
wget --auth-no-challenge \
  --user=$URLuser \
  --password=$URLpw \
  -O urls.html \
  --continue \
  $URLpath


grep -oE 'href="[^"]+\.fq\.gz"' urls.html | \
  sed -E 's/href="([^"]+)"/\1/' | \
  awk -v base_url=$URLpath '{print base_url $0}' > fqurls.txt

grep -oE 'href="[^"]+\.fq\.gz\.md5sums"' urls.html | \
  sed -E 's/href="([^"]+)"/\1/' | \
  awk -v base_url=$URLpath '{print base_url $0}' > md5urls.txt

rm urls.html
