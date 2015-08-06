* FindValue by Raúl Torres October 24,2013

capture program drop findval
program define findval
  version 12
  syntax varlist [if] [in] , VALue(string) VARtype(string)
  
local count =0  

if regexm("`vartype'","str") {
  foreach v of varlist `varlist' {
    qui count if `v'=="`value'"
    if `r(N)'>0   { 
          di "`v'" _dup(`=36-length("`v'")') "." _col(36) "number of obs with that value: `r(N)'"       
          local count = `count'+1
          }
  }
}

else {
  foreach v of varlist `varlist' {
    qui count if `v'==`value' 
    if `r(N)'>0   {
          di "`v'" _dup(`=36-length("`v'")') "." _col(36) "number of obs with that value: `r(N)'"
          local count = `count'+1
          }
  }

} 

if `count'==0 di "value `value' not found"

end
