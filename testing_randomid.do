// testing the seed in randomid

tempfile num1 num2
clear
set seed 111
set obs 50
gen n=_n
randomid id,len(10)
randomid id2,len(10)
save `num1'

clear
set seed 111
set obs 50
gen n=_n
randomid id,len(10)
randomid id2,len(10)
rename id* id*_dtaB
save `num2'

clear 
use `num1'
merge 1:1 n using `num2' ,nogen
li id id_dtaB id2 id2_dtaB , divider string(25) ab(32) sep(10)


// errors
randomid 111
randomid id3,len(1)
randomid id3,len(2)



