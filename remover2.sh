#!/bin/bash

# 1. Remove validate_order.sh
rm validate_order.sh 
cvs rm validate_order.sh 
cvs commit -m "chiroz51: removed  validate_order.sh  from regression" validate_order.sh 

# 2. Replace the validation.sh to Cmp.pl in the compare
sed -i 's/perc_custom_compare validate_order.sh/perc_custom_compare Cmp.pl/g' compare
cvs commit -m "chiroz51: updated compare" compare


# 3. Modify the dofile to replace IF statement with export
# First, capture the CAL_OPTIONS value
cal_value=$(grep 'CAL_OPTIONS=' dofile | sed 's/^[[:space:]]*CAL_OPTIONS=//')

# Then replace the if block with the export statement using the captured value
sed -i '
/if \[ -z "\$CAL_OPTIONS" \]; then/,/fi/{
    /if \[ -z "\$CAL_OPTIONS" \]; then/c\export CAL_OPTIONS='"$cal_value"'
    /CAL_OPTIONS=/d
    /export CAL_OPTIONS/d
    /fi/d
}' dofile

# 4. Switch the order of the lines
sed -i '
/export CAL_OPTIONS/{h;d};
/perc_time_start/{p;g}
' dofile


cvs commit -m "chiroz51: updated dofile" dofile

# 5. Add Cmp.pl script from Masa's Repo:
cp /wv/myoshimo/rerun/regression/PERC-16261_PARALLEL_ORDER/waiver/Cmp.pl .

cvs add Cmp.pl

cvs commit -m "chiroz51: Added Cmp.pl to the regression" Cmp.pl

#----------------------  
# 6. Remove yourself after execution
rm -- "$0"












