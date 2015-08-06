* line by line comparison
cap program drop lblcomp
program define lblcomp /*,sortpreserve*/
 version 12.1
 syntax varlist(min=1)  using/,     ///
            COMPwith(namelist min=1) ///
           [sort(varlist)           ///
            cases(integer 50)       ///
            nolist *]

       
local varlist_base `varlist' 
local varlist_comp `compwith' 
assert `: list sizeof varlist_base' == `: list sizeof varlist_comp'

local masterN=_N
gen _n_ =_n
preserve
  qui use "`using'",clear
  local usingN = _N
  if "`sort'" !="" sort `sort'
  qui gen _n_ = _n
  keep `varlist_comp' _n_
  qui rename (`varlist_comp') cmp_=
  tempfile MERGE
  qui save `MERGE'
restore

if `masterN'!=`usingN' di as error "WARNING: datasets differ in number of observations [_N master="`masterN' " _N using=" `usingN' "]."

qui merge 1:1 _n_ using `MERGE' , gen(_SOURCE)
label define _source_ 1 "base" 2 "comp" 3 "both"
label values _SOURCE _source_

// looping through variables 
forvalues  x=1/`: list sizeof varlist_base'{
  
  // creating cases where two variables differ at a given dataset row
  qui gen d_`: word `x' of `varlist_base'' = `: word `x' of `varlist_base''~=cmp_`: word `x' of `varlist_comp''
  local bigN = _N
  
  // counting the cases where they differ in increments of one
  qui egen _`x'Ncase = seq() if d_`: word `x' of `varlist_base''==1, from(1) to(`bigN') b(1)
  sum d_`: word `x' of `varlist_base'', meanonly
  di as result _n "`: word `x' of `varlist_base'' and `: word `x' of `varlist_comp'' differ in " %4.1f 100*`r(mean)' "% of records"
   
  // if the nolist option is evoked, list the `cases' or max [if max is less than `cases'] cases where the two variables differ
  if "`list'"=="" {
   sum _`x'Ncase, meanonly
   local NcaseMAX = r(max)
   if `NcaseMAX'==. local NcaseMAX = `cases'
   if `cases'>`NcaseMAX' list `: word `x' of `varlist_base'' cmp_`: word `x' of `varlist_comp'' /*_SOURCE*/ if _`x'Ncase <= `NcaseMAX',`options'
   else                 {
                         list `: word `x' of `varlist_base'' cmp_`: word `x' of `varlist_comp'' /*_SOURCE*/ if _`x'Ncase <= `cases'   ,`options'
                         di as text _col(10) %12.0fc `NcaseMAX'-`cases' " differing records ommited"
                         }
  } /* end if "`list'"  */
} /* end forvalues x=1 */
qui label drop _source_                    // drops the labels created suring this ado
qui drop if _SOURCE==2                     // drops the merged in records 
qui drop d_* cmp_* _n_ _SOURCE _*Ncase     // drops the created vars during this ado
end
