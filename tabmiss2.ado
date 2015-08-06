
* Raul Torres 4/22/2015 11:10:48 AM
* Note: this command is intended for numeric variables only
capt program drop tabmiss2
program define tabmiss2
        version 13.0
        syntax [varlist] [if] [in]
        
        di as input _n(2)  "    Variable             {c |}" ///
           _col(34) "Obs        " ///
           _col(46) "Missings   " ///
           _col(58) "Pct.Miss   " ///
           _col(69) "NonMiss    " ///
           _col(80) "Pct.NonMiss"
        di in text "{hline 25}{c +}{hline 65}"
        
        foreach v of local varlist  {
            
            // obtain the set of missing values among the varlist
            confirm numeric variable `v'
            qui levelsof `v' if mi(`v'), missing local(missingset)
            
            // obtain denominator
            qui count `if'
            local N =r(N)
            
            // obtain count of nonmissing values
            qui sum `v' `if' `in'
            local nonmiss=r(N)
            
            // obtain count of missing values total
            tempvar contar                             
            qui egen `contar'= rowmiss(`v') `if' `in'
            qui sum  `contar' if `contar' ==1
            local allmiss = r(N)
            
            // Percents
            local pct_miss = (`allmiss'/`N')*100
            local pct_nonmiss = (`nonmiss'/`N')*100

            // display row for var v
            di as input %25s abbrev("`v'",25) "{c |}" as result ///
                _col(30) %10.0fc `N' ///
                _col(45) %9.0f `allmiss' ///
                _col(61) %4.2f `pct_miss'  ///
                _col(67) %9.0f `nonmiss'  ///
                _col(86) %4.2f `pct_nonmiss'

            // obtain count of missing values by type and display them 
            foreach m of local missingset {
                if "`if'"=="" qui count  if    `v'==`m' `in'
                else          qui count `if' & `v'==`m' `in'
                local miss=r(N)    
                local pct=(r(N)/`N')*100
                if "`m'"=="." di as result _col(23) "`m'  {c |}" as result ///
                   _col(45) %9.0f `miss' ///
                   _col(61) %4.2f `pct'     
                else          di as result _col(23) "`m' {c |}" as result ///
                   _col(45) %9.0f `miss' ///
                   _col(61) %4.2f `pct' 
              }
           di in text "{hline 25}{c +}{hline 65}" 
        }
end
