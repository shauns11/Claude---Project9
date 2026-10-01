
clear
set obs 200
set seed 12345
gen id=_n

* Survey design variables
gen psu = ceil(_n/10)                 // Primary sampling units
gen strata = mod(psu, 5) + 1          // 5 strata
gen wt_int = runiform(0.5, 2.5)        // Sampling weights

* Demographic variables
gen sex = (runiform() > 0.5)           // 0 = female, 1 = male
label define sexlbl 0 "Female" 1 "Male"
label values sex sexlbl

gen age = round(runiform(18, 65))

* Positive outcome variable (e.g., income, expenditure, exposure)
gen income = exp(rnormal(8, 0.6))      // log-normal distribution
gen wealth = exp(rnormal(8, 0.6))      // log-normal distribution

label variable income "Monthly income"
label variable wealth "Household wealth"
label variable wt_int "Survey weight"
label variable psu "Primary sampling unit"
label variable strata "Stratum"

replace income = -8 if _n==1
replace income = -1 if _n==2
replace wealth = -8 if _n==1
replace wealth = -1 if _n==2

summ income
svyset [pw=wt_int],psu(psu) strata(strata)
keep id psu strata wt_int sex age income wealth
save "C:/CLAUDE/Projects/Project9/data/survey_data.dta", replace