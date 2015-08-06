capture program drop tablecells
program define tablecells
  version 12.1
  syntax   [using/],       ///
           [DIsplay]       ///
           [TABle(string)] ///
           [Temp(string)]  ///
           [DEString]      ///
           [Force] 
preserve

*list of variables [columns in the table]
qui ds
local varlist  `r(varlist)'
local sizeofvarlist: list sizeof varlist
local _some_strings =0

*list of var1 values [row titles in the table]
forvalues a=2/`sizeofvarlist' {
  local type: type `:word `a' of `varlist'' 
  if regexm("`type'","str") local _some_strings =1
  rename `: word `a' of `varlist'' s_`:word `a' of `varlist''
}
if `_some_strings'==1 tostring s_*, replace `force' // b/c the reshape won't work unless all variables are string or numeric
reshape long s_, i(`:word 1 of `varlist'') j(j) string
tostring `:word 1 of `varlist'',replace u
tostring s_, replace u
gen str100 varname ="`table'"+`:word 1 of `varlist''+"_"+j
rename s_ values
keep varname values
order varname values
if "`destring'"!="" destring values,replace force
compress

if "`display'" != "" list, noobs sepby(varname)

if "`temp'"    != "" save "`temp'"

if "`using'"   != "" save `using', replace 

restore
end

