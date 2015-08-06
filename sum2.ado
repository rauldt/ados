capture program drop sum2
program define sum2
qui {
 
  version 12.1

 *PARAMETERS AND OPTIONS
  syntax [varlist] [using/],   /// /* Allows varlist and using for exporting purposes*/
         [DESKtop              /// /* Save the codebook as .xls in the desktop*/
          NUMonly              /// /* Produce codebook for numeric variables only*/
          STRonly              /// /* Produce codebook for string variables only*/
          WORKBook(string)     /// /* Excel workbook name*/
          WORKSheet(string)    /// /* Excel worksheet name*/
          Cthresh(integer 7)   /// /* Max number of levels in order for variable to be considered categorical*/
          string(integer 31)   /// /* Length of displayed strings [only for display, not exporting]*/
          LValues(integer 15)  /// /* Length of values variable, [you may want to increase if value labels >15] */
          SUPress(namelist max=7)] /* List of columns to suppress from display [only for display, not exporting]*/ 
 
 *ERRORS 
  
  // using and export can't go together
  if "`using'"!="" & "`desktop'"=="desktop"{
    noi di as error "option desktop not allowed with using path/name"
    exit 9053 
    }
  
  // varlist and the options numeric/string can't go togheter
  qui ds
  local test_varlist `r(varlist)'
  local TEST: list varlist === test_varlist 
  if `TEST'==0 & ("`numonly'"=="numonly" | "`stronly'"=="stronly") {
    noi di as error "option numonly/stronly not allowed with varlist"
    exit 9053
    }
  
  // numonly and stronly can't go together
  if "`numonly'"=="numonly" & "`stronly'"=="stronly" {
    noi di as error "option numonly not allowed with option stronly"
    exit 9053
    }
  
  // ensure the names in supress are valid
  if "`supress'"!="" {
    local A  varnum N Nmissing Ndistinct mean min max
    local ERR: list supress - A
    if "`ERR'"!="" {
      noi di as error "supress element(s) `ERR' invalid."
      noi di as error _col(3) "Valid elements include `A'"
      exit 9053
    }
  }
    
 *COMMAND ACTIONS
 
  // save original dataset 
  tempfile c_file
  save `c_file'  
  clear

  // Counter variable
  local i = 1

  // Initializing dataset for appending
  set obs 1
  gen str`lvalues' values = "zztempzz"
  tempfile appendds
  save "`appendds'"
  clear

  // Using dataset
  use "`c_file'"
  
  // Looping across dataset variables
    
  if "`numonly'" =="numonly" { 
       qui ds, has(type numeric)
       local varlist `r(varlist)'
       }
  if "`stronly'" =="stronly" {
       qui ds, has(type string)
       local varlist `r(varlist)'
       }
  
  foreach var of varlist `varlist' {
  
  preserve

    // Keeping only one variable at a time
    keep `var'
    rename `var' values

    // Retain value label
    local valuelab "`: value label values'"
    
    // Obtaining N, N-distinct, n-missing, and [mean, max and min] if string.
    if regexm("`: type values'","str") == 1 {
      count
      local N=r(N)
      
      distinct
      local Ndistinct=r(ndistinct)
      
      count if mi(values)
      local Nmissing=r(N)
      
      local mean .
      local min  .
      local max  .
    }
    else {
      count
      local N=r(N)
      
      distinct 
      local Ndistinct=r(ndistinct)
      
      count if mi(values)
      local Nmissing=r(N)
    
      summ values, meanonly
      local mean : display %9.4f r(mean)
      local min  =r(min)
      local max  =r(max)
    }

    // Collapse data so that there is one record per value
    capt contract values
    drop _freq

    // Remove missing values
    drop if missing(values)==1

    // If zero nonmissing records, set as empty
    local empty = 0
    if _N==0 {
      set obs 1
      capt tostring values, replace force
      replace values = "all missing" /*<-- "all missing"*/
      local empty = 1
    }

    // Obtaining variable name
    gen str33 name   = "`var'"
    
    // Obtaining variable label
    gen str80 label = "`: variable label values'"

    // Counter variable [increases by one per variable in varlist]
    gen int varnum = `i++'

    // Only execute STR/NUMERIC code over variables with at least one observation
    if `empty'==0 {

      // If the variable is a string, keeping only first observation
      if strpos(upper("`: type values'"),"STR") > 0 {

        keep if _n==1
        replace values = "`: type values'"
        
        gen N = `N'
        gen Ndistinct  = `Ndistinct'
        gen Nmissing   = `Nmissing'  
        gen mean       = `mean'
        gen min        = `min'
        gen max        = `max'
       } 

      
      // If the variable is numeric, do the following
      else {

        // If gt categorical threshold, keep only first obs and call continuous
        if `c(N)' > `cthresh' {

          keep if _n==1
          drop values
          
          // obtaining label value name
          gen str`lvalues' values = "Continuous"
          
        }
        
        /* If le categorical threshold, then keep the data as is, but create a string variable that
           contains the resolved format for each level*/
        else {

         // If values are labeled, reapplying value labels (lost during contract command) and converting to string
         if "`valuelab'" != "" {

             label values values `valuelab' /*1st values==command, 2nd values==variable name*/
             rename values values_old
             decode values_old, generate(values)
             drop values_old
             }
             
             
         // Otherwise, just converting to string
         else tostring values, replace force
        
        }   /*(END) NUM-only*/

         gen N = `N'
         gen Ndistinct =  `Ndistinct'
         gen Nmissing  =  `Nmissing'  
         gen mean       = `mean'
         gen min        = `min'
         gen max        = `max'

      }     /*(END) STR/NUMERIC*/

    }       /*(END) Not empty*/
    
    // Appending/resaving
    append using `appendds'
    save `appendds', replace

  restore

  }         /* (END) _all variables*/

  // Cleaning up appended data
  clear
  use `appendds'
  drop if values == "zztempzz"
  sort varnum values

  //Keeping only the first occurance of variable name/label
  bysort varnum: replace name  = "" if _n>1
  bysort varnum: replace label = "" if _n>1

  // Display
  qui compress
  order varnum name label values N Nmissing Ndistinct mean min max
  
    // Length of String
    
  
    // if supress is not invoked, display everything
  if "`supress'"==""  nois list, abb(30) str(`string') noobs clean
  
    // if supress is invoked, display all - supress list
  if "`supress'"!="" {
     local A  varnum name label values N Nmissing Ndistinct mean min max
     local di_list: list A - supress 
     noi list `di_list', abb(30) str(`string') noobs clean
     }
     

  // Exporting as XLS
  if "`workbook'"=="" local workbook codebook
  if "`desktop'"=="desktop"{
   local trimpath  = strpos("$S_FN","AppData")-1
   local location `: di substr("$S_FN",1,`trimpath')'Desktop
   noi export excel _all using "`location'\\`workbook'.xlsx", firstrow(variables) sheet("`worksheet'") replace
  }
  
  if "`using'"!="" noi export excel _all using "`using'.xlsx", firstrow(variables) sheet("`worksheet'") sheetreplace
  
  
  //Bringing original dataset
  use `c_file',clear
  
}   /* (END) quietly */
end /* (END) program */


