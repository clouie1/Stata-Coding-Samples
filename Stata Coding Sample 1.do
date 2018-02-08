**************************************************************************
** Econ 216 Assignment 7 
** By Christina Louie
** Date: November 23, 2016
**************************************************************************

clear all
set more off

*Set Directory
cd "C:\Users\ChristinaL\Documents\Econ 216"


*----------------------------------------
* ------------ QUESTION 1 ---------------
*----------------------------------------

*Read in Data
use "C:\Users\ChristinaL\Documents\Econ 216\Data\assign7_minimum_wage.dta", clear

* -- PART A --
twoway (histogram wagest if NJ==1 & wave==1, color(purple)) ///
	(histogram wagest if NJ==1 & wave==2), ///
	legend(order(1 "February" 2 "November")) ///
	title("Histogram of Wages in New Jersey -Before and After") ///
	xtitle("Wages")
graph export "Assignment\assign7_histnj.png", replace

* -- PART B --
*fixing the labeling of wave
gen after =.
replace after=0 if wave==1
replace after=1 if wave==2

*Running regression using single-difference method, including
*fixed effects and account for heteroskedastic errors 
areg wagest after, absorb(storeid) robust
outreg2 using assign7_singlediff.tex, replace label bdec(3) sdec(3) ///
	ctitle("Wages")

areg emp after, absorb(storeid) robust
outreg2 using assign7_singlediff.tex, append label bdec(3) sdec(3) ///
	ctitle("Num. of Employee")

areg hrsopen after, absorb(storeid) robust
outreg2 using assign7_singlediff.tex, append label bdec(3) sdec(3) ///
	ctitle("Hours Open")
	
areg pentree after, absorb(storeid) robust
outreg2 using assign7_singlediff.tex, append label bdec(3) sdec(3) ///
	ctitle("Price (Entree)")

* -- PART D ----
*Generate the Diference-in-Difference Variable
gen NJ_after = NJ*after

*Running regression using difference-in-difference method, 
*accounting for heteroskedastic errors 
reg wagest NJ after NJ_after, robust
outreg2 using assign7_diffindiff.tex, replace label bdec(3) sdec(3) ///
	ctitle("Wages")
	
reg emp NJ after NJ_after, robust
outreg2 using assign7_diffindiff.tex, append label bdec(3) sdec(3) ///
	ctitle("Num. of Employee")

reg hrsopen NJ after NJ_after, robust
outreg2 using assign7_diffindiff.tex, append label bdec(3) sdec(3) ///
	ctitle("Hours Open")
	
reg pentree NJ after NJ_after, robust
outreg2 using assign7_diffindiff.tex, append label bdec(3) sdec(3) ///
	ctitle("Price (Entree)")
	

*----------------------------------------
* ------------ QUESTION 2 ---------------
*----------------------------------------
clear all
set more off

*Read in Data
use "C:\Users\ChristinaL\Documents\Econ 216\Data\assign7_minimum_wage.dta", clear

* PART A *
keep if NJ==1
gen lower_wage = 1 if wagest<5.05 & wave==1
replace lower_wage=0 if wave==1 & missing(lower_wage)
by storeid, sort: egen treatNJ = total(lower_wage)
order storeid treatNJ lower_wage wagest

gen afterApril =.
replace afterApril = 1 if wave==2
replace afterApril = 0 if wave==1

gen treatNJ_afterApril = treatNJ*afterApril

reg wagest treatNJ afterApril treatNJ_afterApril, robust
outreg2 using assign7_q2a.tex, replace label bdec(3) sdec(3) ///
	ctitle("Wages")

reg emp treatNJ afterApril treatNJ_afterApril, robust
outreg2 using assign7_q2a.tex, append label bdec(3) sdec(3) ///
	ctitle("Num. of Employee")

reg hrsopen treatNJ afterApril treatNJ_afterApril, robust
outreg2 using assign7_q2a.tex, append label bdec(3) sdec(3) ///
	ctitle("Hours Open")
	
reg pentree treatNJ afterApril treatNJ_afterApril, robust
outreg2 using assign7_q2a.tex, append label bdec(3) sdec(3) ///
	ctitle("Price (Entree)")

* PART B*
clear all
set more off

*Read in Data
use "C:\Users\ChristinaL\Documents\Econ 216\Data\assign7_minimum_wage.dta", clear

reshape wide psoda pfries pentree wagest hrsopen emp compown ///
	chain income county, i(storeid) j(wave)

gen GAP = 5.05 - wagest1

replace GAP = 0 if GAP<0
replace GAP = 0 if state ==2 & GAP !=.

gen diff_emp = emp2 - emp1
gen diff_hrsopen = hrsopen2 - hrsopen1
gen diff_pentree = pentree2 - pentree1

reg diff_emp GAP, robust
outreg2 using assign7_q2b.tex, replace label bdec(3) sdec(3) ///
	ctitle("Diff. in Employ")

reg diff_hrsopen GAP, robust
outreg2 using assign7_q2b.tex, append label bdec(3) sdec(3) ///
	ctitle("Diff. in Hours Open")
	
reg diff_pentree GAP, robust
outreg2 using assign7_q2b.tex, append label bdec(3) sdec(3) ///
	ctitle("Diff. in Price (Entree)")
	
	
*----------------------------------------
* ------------ QUESTION 3 ---------------
*----------------------------------------
clear all 
set more off

*Read in Data 
use "C:\Users\ChristinaL\Documents\Econ 216\Data\assign7_reminder.dta", clear

* PART A*
*Comparison of the means
foreach x in inc male age fsize {
	ttest `x', by(reminder)
}

* PART B and C*
*Running Regression
reg p401k reminder
outreg2 using assign7_q3b.tex, replace label bdec(3) sdec(3) ///
	ctitle("P401k")

reg p401k reminder inc male age fsize
outreg2 using assign7_q3b.tex, append label bdec(3) sdec(3) ///
	ctitle("P401k")

* PART D* 
*Calculate propensity score
reg reminder inc male age fsize
outreg2 using assign7_q3d.tex, replace label bdec(3) sdec(3) ///
	ctitle("Reminder")
predict propen

*Average propensity score
sum propen if reminder==1
sutex 

sum propen if reminder==0
sutex

*Sort by Propensity Score
gsort -propen -reminder
order propen reminder

*** Adjacent Observations
gen cool = 1 if reminder==1 & reminder[_n-1]==0 & reminder[_n+1]==0
gen diff_up = abs(propen-propen[_n+1]) if cool==1
gen diff_low = abs(propen-propen[_n-1]) if cool==1

*Generate match variable
gen match=.
replace match=1 if diff_up[_n-1]<diff_low[_n-1] & cool[_n-1]==1
replace match=1 if diff_low[_n+1]<diff_up[_n+1] & cool[_n+1]==1

*** Non-adjacent Obs (394)
replace cool=0 if reminder==1 & missing(cool)

*Diff Above
replace diff_up = abs(propen-propen[_n+1]) if cool==0 & reminder[_n+1]==0
replace diff_up = abs(propen-propen[_n+2]) if cool==0 & reminder[_n+1]==1 & reminder[_n+2]==0

*Diff Below
replace diff_low = abs(propen-propen[_n-1]) if cool==0 & reminder[_n-1]==0
replace diff_low = abs(propen-propen[_n-2]) if cool==0 & reminder[_n-1]==1 & reminder[_n-2]==0

*Match (if high is better)
replace match=1 if diff_up[_n-1]<diff_low[_n-1] & reminder==0 & cool[_n-1]==0
replace match=1 if diff_up[_n-2]<diff_low[_n-2] & reminder==0 & reminder[_n-1]==1 & cool[_n-2]==0

*Match (if low is better)
replace match=1 if diff_low[_n+1]<diff_up[_n+1] & reminder==0 & cool[_n+1]==0
replace match=1 if diff_low[_n+2]<diff_up[_n+2] & reminder==0 & reminder[_n+1]==1 & cool[_n+2]==0

** Keep only the matched & treated observations
keep if match==1 | reminder==1
foreach x in inc male age fsize {
	ttest `x', by(reminder)
}

*PART F *
reg p401k reminder
outreg2 using assign7_q3f.tex, replace label bdec(3) sdec(3) ///
	ctitle("P401k")

reg p401k reminder inc male age fsize
outreg2 using assign7_q3f.tex, append label bdec(3) sdec(3) ///
	ctitle("P401k")








