# ---------------------------------
rm check_remotes.pl
cvs remove check_remotes.pl
cvs commit -m "chiroz51: removed check_remotes.pl from regression " check_remotes.pl

# ---------------------------------

rm do_st
cvs remove do_st
cvs commit -m "chiroz51: removed do_st from regression " do_st

# ---------------------------------

rm out_file
cvs remove out_file
cvs commit -m "chiroz51: removed out_file from regression " out_file

# ---------------------------------

rm st_result.tar.gz
cvs remove st_result.tar.gz
cvs commit -m "chiroz51: removed st_result.tar.gz from regression " st_result.tar.gz


# ---------------------------------
#compare
cvs commit -m "chiroz51: Updated compare  " compare 


# ---------------------------------
#dofile

cvs commit -m "chiroz51: Updated dofile  " dofile


# ---------------------------------
rm baseline/Top.percw
rm baseline/qaout.perc.rep
rm baseline/qaout.perc.rep_load0 
rm baseline/qaout.perc.rep_load1
rm baseline/qaout.perc.rep_load2

cvs remove baseline/Top.percw
cvs remove baseline/qaout.perc.rep
cvs remove baseline/qaout.perc.rep_load0 
cvs remove baseline/qaout.perc.rep_load1
cvs remove baseline/qaout.perc.rep_load2

cvs commit -m "chiroz51: Removed   baseline/Top.percw            " baseline/Top.percw
cvs commit -m "chiroz51: Removed   baseline/qaout.perc.rep       " baseline/qaout.perc.rep
cvs commit -m "chiroz51: Removed   baseline/qaout.perc.rep_load0 " baseline/qaout.perc.rep_load0 
cvs commit -m "chiroz51: Removed   baseline/qaout.perc.rep_load1 " baseline/qaout.perc.rep_load1
cvs commit -m "chiroz51: Removed   baseline/qaout.perc.rep_load2 " baseline/qaout.perc.rep_load2

#----------------------
# Remove yourself after execution
rm -- "$0"





