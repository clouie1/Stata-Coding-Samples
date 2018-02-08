******************************************************************
*Econ 216 Assignment 8 
*By Christina Louie
*Date: December 2, 2016
******************************************************************

clear all
set more off

*Set in Directory
cd "C:\Users\ChristinaL\Documents\Econ 216"

*==================== QUESTION 1 ========================
*Read in Data
use "Data\assign8_union_workers", clear

** PART A **
reg lwage union, robust
outreg2 using assign7_q1ab.tex, replace label bdec(3) sdec(3) ///
	ctitle("ln(Wage)")

** PART B **
reg lwage union black hisp educ, robust
outreg2 using assign8_q1ab.tex, append label bdec(3) sdec(3) ///
	ctitle("ln(Wage)")

** PART D **
areg lwage union, absorb(nr) robust
outreg2 using assign8_q1d.tex, replace label bdec(3) sdec(3) ///
	ctitle("ln(Wage)")

** PART F **
reg lwage union i.year, robust
outreg2 using assign8_q1f.tex, replace label bdec(3) sdec(3) ///
	ctitle("ln(Wage)")
	
areg lwage union i.year, absorb(nr) 
outreg2 using assign8_q1f.tex, append label bdec(3) sdec(3) ///
	ctitle("ln(Wage)")

*reg lwage union i.year i.nr, robust
*Produce the same result as above (second reg in part f)



*==================== QUESTION 3 ===========================
clear all
*Set in Directory
cd "C:\Users\ChristinaL\Documents\Econ 216"

*Read in data
use "Data\assign8_michigan_state", clear

** PART A **
reg colGPA skipped, robust
outreg2 using assign8_q2.tex, replace label bdec(3) sdec(3) ///
	ctitle("colGPA")
	
reg colGPA skipped hsGPA ACT soph junior senior engineer, robust
outreg2 using assign8_q2.tex, append label bdec(3) sdec(3) ///
	ctitle("colGPA")

** PART B **
** TEST INCLUSION **
reg skipped drive, robust
outreg2 using assign8_q2.tex, append label bdec(3) sdec(3) ///
	ctitle("Skipped")
** not possible tot test exclusion

** PART C **
ivreg colGPA (skipped = drive), robust
outreg2 using assign8_q2.tex, append label bdec(3) sdec(3) ///
	ctitle("colGPA -IV")

ivreg colGPA hsGPA ACT soph junior senior engineer (skipped = drive), robust
outreg2 using assign8_q2.tex, append label bdec(4) sdec(4) ///
	ctitle("colGPA -IV")

** PART D **
reg skipped drive hsGPA ACT soph junior senior engineer, robust
outreg2 using assign8_q2.tex, append label bdec(3) sdec(3) ///
	ctitle("Skipped -2SLS")	
predict skipped_hat

reg colGPA skipped_hat hsGPA ACT soph junior senior engineer, robust
outreg2 using assign8_q2.tex, append label bdec(4) sdec(4) ///
	ctitle("colGPA -2SLS")
	

	
*==================== QUESTION 4 ===========================
clear all
*Set in Directory
cd "C:\Users\ChristinaL\Documents\Econ 216"

*Read in data
use "Data\assign8_deficit_vote", clear

** PART A **
scatter deficit_change dem_vote_share
graph export "Assignment\assign8_scatterdefdem.png", replace

** PART B **
reg deficit_change dem_governor
outreg2 using assign8_q4.tex, replace label bdec(3) sdec(3) ///
	ctitle("Deficit")
predict def

*Graph
twoway (scatter deficit_change dem_vote_share) ///
	(line def dem_vote_share if dem_vote_share < 0.5) ///
	(line def dem_vote_share if dem_vote_share > 0.5)
graph export "Assignment\assign8_scatter4b.png", replace

	
** ---PART C--- **
gen dem_vote_centered = dem_vote_share - 0.5
reg deficit_change dem_governor dem_vote_centered
predict deficit_hat
outreg2 using assign8_q4.tex, append label bdec(3) sdec(3) ///
	ctitle("Deficit - RD")
	
*Graph
twoway (scatter deficit_change dem_vote_share) ///
	(line deficit_hat dem_vote_share if dem_vote_share < 0.5) ///
	(line deficit_hat dem_vote_share if dem_vote_share > 0.5)
graph export "Assignment\assign8_scatter4c.png", replace


** ---PART D--- **
gen dem_vote_centered2 = dem_vote_centered * dem_vote_centered
gen dem_vote_centered3 = dem_vote_centered * dem_vote_centered * dem_vote_centered

reg deficit_change dem_governor dem_vote_centered dem_vote_centered2 dem_vote_centered3
predict def_hat
outreg2 using assign8_q4.tex, append label bdec(3) sdec(3) ///
	ctitle("Deficit - RD cubic")

*Graph
twoway (scatter deficit_change dem_vote_share) ///
	(line def_hat dem_vote_share if dem_vote_share < 0.5) ///
	(line def_hat dem_vote_share if dem_vote_share > 0.5)
graph export "Assignment\assign8_scatter4d.png", replace


** ---PART E--- ***
gen gov_vote = dem_governor * dem_vote_centered
reg deficit_change dem_governor dem_vote_centered gov_vote
outreg2 using assign8_q4.tex, append label bdec(3) sdec(3) ///
	ctitle("Deficit - RD separate")
predict defhat

*Graph
twoway (scatter deficit_change dem_vote_share) ///
	(line defhat dem_vote_share if dem_vote_share < 0.5) ///
	(line defhat dem_vote_share if dem_vote_share > 0.5)
graph export "Assignment\assign8_scatter4e.png", replace


** ---PART F---**
reg deficit_change dem_governor dem_vote_centered if abs(dem_vote_centered)<=0.1
predict defhat_lim
outreg2 using assign8_q4.tex, append label bdec(3) sdec(3) ///
	ctitle("Deficit - RD 0.1")

*Graph
twoway (scatter deficit_change dem_vote_share if abs(dem_vote_centered)<=0.1) ///
	(line defhat_lim dem_vote_share if dem_vote_share < 0.5) ///
	(line defhat_lim dem_vote_share if dem_vote_share > 0.5)
graph export "Assignment\assign8_scatter4f.png", replace
