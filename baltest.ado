
*! version 1.12 -- developed by RT 4/24/2014 
capture program drop baltest
program define baltest
  version 13.1
  syntax anything, PSMvar(varname) OBSvar(varname) [SIGlevel(real .05) sigsort N SAVEMatched(string) cntrep(varname)]


tempfile _0000fl _000trt _000using
qui save `_000using'
tempname _0000nm
gen _0000matched = !mi(`psmvar')
postfile `_0000nm' str32 variable mean_trt mean_con diff str3 sig pval trt_N con_N using `_0000fl'

// cleaning varlist from i.var and c.var terms
foreach _a in `anything' {
  local _000parsed = substr("`_a'",2,1)   
  if "`_000parsed'" =="." local _a  =substr("`_a'",3,length("`_a'"))  
  local varlist_2 `varlist_2' `_a'
}  

// save treated
preserve
qui keep if `e(tvar)'==1 & !mi(`psmvar')
qui save `_000trt'
restore

// save controls
preserve
qui keep if `e(tvar)'==0 
qui drop `psmvar' 
qui rename `obsvar' `psmvar'
qui merge 1:m `psmvar' using `_000trt', keepusing(`psmvar') 
qui keep if _merge==3
qui drop _merge

// append [matched] treated with controls [matches]
qui append using `_000trt'
if "`cntrep'"!="" duplicates report `cntrep' if `e(tvar)'==0
if "`savematched'"!="" save "`savematched'"

// t-tests 
qui distinct `psmvar' if `e(tvar)'==0      
local _000conN  `r(ndistinct)'
foreach _000v of varlist `varlist_2'  {
       
       qui ttest `_000v' , by(`e(tvar)')
       local _000mtrt = round(r(mu_2),.0001)
       local _000mcon = round(r(mu_1),.0001)
       local _000diff = round(r(mu_2) - r(mu_1),.0001)
       local _000pval = `:di %09.5f `r(p)''
       local _000trtN = r(N_2)
      *local _000conN = r(N_1)
       
       if `r(p)'<=`siglevel' local _000star = "*"
       if `r(p)'> `siglevel' local _000star = ""
       
       post `_0000nm' ("`_000v'") (`_000mtrt') (`_000mcon') (`_000diff') ("`_000star'") (`_000pval')  (`_000trtN') (`_000conN')
      }
postclose `_0000nm'
use `_0000fl', clear
noi di as input _n _continue "balance test"
if "`sigsort'"!="" gsort pval variable

if "`n'"!="" noi list variable mean_??? diff sig pval trt_N con_N , noobs abb(25) table sep(100)
else         noi list variable mean_??? diff sig pval             , noobs abb(25) table sep(100)
restore

use `_000using',clear
end
