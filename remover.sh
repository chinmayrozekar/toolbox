#!/bin/bash
#validate_order.sh
cvs add validate_order.sh
cvs commit -m "chiroz51: Adding validate_order.sh to regression" validate_order.sh

#compare
cvs commit -m "chiroz51: updating compare to add validate_order.sh" compare

#----------------------
#Dofile 
cvs commit -m "chiroz51: Updated dofile with greps" dofile 

# Go in the main dir
rm mini_cpu_chip.perc
cvs remove mini_cpu_chip.perc

rm mini_cpu_chip.percw
cvs remove mini_cpu_chip.percw

cvs commit -m "removed mini_cpu_chip.perc &  mini_cpu_chip.percw " mini_cpu_chip.perc mini_cpu_chip.percw 

#----------------------
# Baseline

cd baseline/

rm mini_cpu_chip.perc
cvs remove mini_cpu_chip.perc

rm mini_cpu_chip.percw
cvs remove mini_cpu_chip.percw

cvs commit -m "removed mini_cpu_chip.perc &  mini_cpu_chip.percw " mini_cpu_chip.perc mini_cpu_chip.percw 

cd ..

#----------------------
# Remove yourself after execution
rm -- "$0"



