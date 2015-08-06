*! version 1.4 -- revised 3/26/2014 
capture program drop mprtab
program define mprtab
  version 12
  syntax varlist [if] [in] [, Sort(string) Perc(string) nocum ABbreviate(integer 32) *]
  
  qui count `if'
  if `r(N)'==0 {
   di as result "no observations"
  }

  else {
  preserve

  contract `varlist' `if' `in' , freq(_Freq_)
  if "`sort'" == "+f" {
    gsort +_Freq_ 
  }
  else if "`sort'" == "-f" {
    gsort -_Freq_  
  } 
  else {
    gsort `varlist'
  }
  generate _CFreq_ = sum(_Freq_)
  generate _Perc_ = (_Freq_ / _CFreq_[_N])*100
  generate _CPerc_ = (_CFreq_ / _CFreq_[_N])*100
  format _Freq_ _CFreq_ %5.0f
  format _Perc_ _CPerc_ %6.2f
  
  local clean clean  
  if "`options'"!="" {
       local clean 
    }

  if "`cum'"!="" {
       list `varlist' _Freq_ _Perc_                 , noobs `clean' abb(`abbreviate') `options' 
    }
  
  else list `varlist' _Freq_ _Perc_ _CFreq_ _CPerc_ , noobs `clean' abb(`abbreviate') `options' 
  
  restore
  } /* end else on 13 */
end


