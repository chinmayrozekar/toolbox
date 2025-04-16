#!/bin/bash

cleanup_output_files_to_change=$(cat ./files)
readarray -t compareArray <<< "$cleanup_output_files_to_change"


for i in "${compareArray[@]}"
do

    # step 1:copy the cleanup_outputfile from baselineTC to all the TC's
    echo "Copied ./baseline_TC/cleanup_output to $i which had rm run.log in it"
    cp ./baseline_TC/cleanup_output $i

    #step 2: CVS commit 

    cvs commit -m "chiroz51: Added rm run.log to $i" $i
done
