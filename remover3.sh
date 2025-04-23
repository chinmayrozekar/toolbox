#!/bin/bash


files=(
  "Cmp.pl"
  "compare"
  "CVS"
  "dofile"
  "rules"
  "setup_tst"
  "src.net"
  "TESTINFO.json"
  "baseline/curr_ew"
  "baseline/qaout.log"
  "baseline/qaout.perc.rep"
)

for file in "${files[@]}";do

   echo "Removing $file ..."
   rm "$file"
   cvs rm "$file"
   cvs ci -m "chiroz51: removed $file from regression" "$file"
done



