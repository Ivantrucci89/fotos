#!/usr/bin/env sh
# Filter out images with broken links
# This script assumes that you pass in three arguments:
#   argument 1 = root directory for images
#   argument 2 = text file containing URLs for images to download
#   argument 3 = directory where downloaded images will be stored (relative to root directory)

for i in `cat $1/$2` 
do
    wget -o wget_results.txt --spider $i
    httpCount=$(grep -c -i "HTTP request sent" wget_results.txt)
    if [ $httpCount -eq 1 ]; then
        echo "Fetching $i"
        wget -o summary.txt --directory-prefix=$1/$3 $i
    else
        echo "Skipping $i"
    fi 
done