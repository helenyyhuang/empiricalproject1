* Do-File for Empirical Project 1
* Author: Helen (Yingying) Huang
* Date: 11/17/2023
* Purpose: Analyze and describe data using the Opportunity Atlas to understand 
* economic opportunity based on geographic and demographic factors.
* Dataset: atlas.dta
* Stata Version: 17
version 17

* Change directory to 'project1'
cd "../project1"

* Set relative paths for the data and log files
local datapath "./"
local dataset "atlas.dta"
local logfile "empiricalproject1_helen.log"

* Start log file to record session
log using "`datapath'`logfile'", replace

* Load the dataset
use "`datapath'`dataset'", clear

* Error checking after loading data to ensure the file exists and is not empty
if _rc {
    di "Error: Dataset could not be loaded. Please check the file path."
    exit 1
}

* Question 3: Upward Mobility Analysis
* -----------------------------------
* Compare upward mobility in Tract 24510130600 to state and U.S. averages

* Calculate the average upward mobility for children with parents at the 25th percentile (kfr_pooled_p25) in Tract 24510130600, Hampden, Baltimore, MD
sum kfr_pooled_p25 if state == 24 & county == 510 & tract == 130600 [aw = count_pooled ]
local tract_weighted_avg = r(mean)

* Calculate the population-weighted average of the variable "kfr_pooled_p25" for Maryland
sum kfr_pooled_p25 if state == 24 [aw=count_pooled] 
local weighted_sum_maryland = r(sum)
sum count_pooled if state == 24
local total_count_maryland = r(sum)
local maryland_weighted_avg = `weighted_sum_maryland' / `total_count_maryland'

* Calculate the population-weighted average of the variable "kfr_pooled_p25" for the entire U.S.
sum kfr_pooled_p25 [aw=count_pooled]
local weighted_sum_us = r(sum)
sum count_pooled
local total_count_us = r(sum)
local us_weighted_avg = `weighted_sum_us' / `total_count_us'

* Display results
display "The population-weighted average kfr_pooled_p25 for Tract 24510130600 is `tract_weighted_avg'"
display "The population-weighted average kfr_pooled_p25 for Maryland is `maryland_weighted_avg'"
display "The population-weighted average kfr_pooled_p25 for the U.S. is `us_weighted_avg'"

* Question 4: Variability Analysis
* -------------------------------
* Compare standard deviations of upward mobility

* Calculate the weighted kfr for each observation for the 25th percentile
gen weighted_kfr = kfr_pooled_p25 * count_pooled if !missing(kfr_pooled_p25) & !missing(count_pooled)

* Calculate the weighted mean of kfr for for the 25th percentile for Baltimore County, Maryland, and the US
egen sum_weighted_kfr_balt = total(weighted_kfr) if state == 24 & county == 510
egen sum_weights_balt = total(count_pooled) if state == 24 & county == 510
gen weight_mean_kfr_balt = sum_weighted_kfr_balt / sum_weights_balt if !missing(sum_weights_balt)

egen sum_weighted_kfr_md = total(weighted_kfr) if state == 24
egen sum_weights_md = total(count_pooled) if state == 24
gen weight_mean_kfr_md = sum_weighted_kfr_md / sum_weights_md if !missing(sum_weights_md)

egen sum_weighted_kfr_us = total(weighted_kfr)
egen sum_weights_us = total(count_pooled)
gen weight_mean_kfr_us = sum_weighted_kfr_us / sum_weights_us if !missing(sum_weights_us)

* Calculate the deviation and weighted sum of squared deviations for the 25th percentile for Baltimore County, Maryland, and the US
gen deviation_balt = kfr_pooled_p25 - weight_mean_kfr_balt if state == 24 & county == 510 & !missing(kfr_pooled_p25)
gen weighted_dev_sq_balt = deviation_balt^2 * count_pooled if state == 24 & county == 510 & !missing(deviation_balt)
egen total_wdev_sq_balt = total(weighted_dev_sq_balt) if state == 24 & county == 510

gen deviation_md = kfr_pooled_p25 - weight_mean_kfr_md if state == 24 & !missing(kfr_pooled_p25)
gen weighted_dev_sq_md = deviation_md^2 * count_pooled if state == 24 & !missing(deviation_md)
egen total_wdev_sq_md = total(weighted_dev_sq_md) if state == 24

gen deviation_us = kfr_pooled_p25 - weight_mean_kfr_us if !missing(kfr_pooled_p25)
gen weighted_dev_sq_us = deviation_us^2 * count_pooled if !missing(deviation_us)
egen total_wdev_sq_us = total(weighted_dev_sq_us)

* Calculate the total weights and the total weighted sum of squared deviations for the 25th percentile for Baltimore County, Maryland, and the US
sum count_pooled if state == 24 & county == 510
local total_weight_balt = r(sum)
sum weighted_dev_sq_balt if state == 24 & county == 510
local total_dev_sq_balt = r(sum)

sum count_pooled if state == 24
local total_weight_md = r(sum)
sum weighted_dev_sq_md if state == 24
local total_dev_sq_md = r(sum)

sum count_pooled 
local total_weight_us = r(sum)
sum weighted_dev_sq_us
local total_dev_sq_us = r(sum)

* Calculate the weighted standard deviation for the 25th percentile for Baltimore County, Maryland, and the US
local std_dev_balt = sqrt(`total_dev_sq_balt' / `total_weight_balt')
local std_dev_md = sqrt(`total_dev_sq_md' / `total_weight_md')
local std_dev_us = sqrt(`total_dev_sq_us' / `total_weight_us')

* Display the results
display "Weighted Standard Deviation for Baltimore County at the 25th percentile: " `std_dev_balt'
display "Weighted Standard Deviation for Maryland State at the 25th percentile: " `std_dev_md'
display "Weighted Standard Deviation for U.S. at the 25th percentile: " `std_dev_us'

* Question 5: Downward Mobility Analysis & Variability Analysis
* -----------------------------------
* Compare the downward mobility and its standard deviations in Tract 24510130600 to the state and U.S. averages

* Calculate the average downward mobility for children with parents at the 75th percentile (kfr_pooled_p75) in Tract 24510130600, Hampden, Baltimore, MD
sum kfr_pooled_p75 if state == 24 & county == 510 & tract == 130600 [aw = count_pooled ] 
local tract_weighted_avg_p75 = r(mean)

* Calculate the population-weighted average of "kfr_pooled_p75" for Maryland
sum kfr_pooled_p75 if state == 24 [aw=count_pooled] 
local weighted_sum_maryland = r(sum)
sum count_pooled if state == 24
local total_count_maryland = r(sum)
local maryland_weighted_avg = `weighted_sum_maryland' / `total_count_maryland'

* Calculate the population-weighted average of "kfr_pooled_p75" for the entire U.S.
sum kfr_pooled_p75 [aw=count_pooled] 
local weighted_sum_us = r(sum)
sum count_pooled
local total_count_us = r(sum)
local us_weighted_avg = `weighted_sum_us' / `total_count_us'

* Display results
display "The population-weighted average kfr_pooled_p75 for Tract 24510130600 is `tract_weighted_avg_p75'"
display "The population-weighted average kfr_pooled_p75 for Maryland is `maryland_weighted_avg'"
display "The population-weighted average kfr_pooled_p75 for the U.S. is `us_weighted_avg'"

* Calculate the weighted kfr for each observation for the 75th percentile
gen weighted_kfr_p75 = kfr_pooled_p75 * count_pooled if !missing(kfr_pooled_p75) & !missing(count_pooled)

* Calculate the weighted mean of kfr for the 75th percentile for Baltimore County, Maryland, and the US
egen sum_weighted_kfr_balt_p75 = total(weighted_kfr_p75) if state == 24 & county == 510
egen sum_weights_balt_p75 = total(count_pooled) if state == 24 & county == 510
gen weight_mean_kfr_balt_p75 = sum_weighted_kfr_balt_p75 / sum_weights_balt_p75 if !missing(sum_weights_balt_p75)

egen sum_weighted_kfr_md_p75 = total(weighted_kfr_p75) if state == 24
egen sum_weights_md_p75 = total(count_pooled) if state == 24
gen weight_mean_kfr_md_p75 = sum_weighted_kfr_md_p75 / sum_weights_md_p75 if !missing(sum_weights_md_p75)

egen sum_weighted_kfr_us_p75 = total(weighted_kfr_p75)
egen sum_weights_us_p75 = total(count_pooled)
gen weight_mean_kfr_us_p75 = sum_weighted_kfr_us_p75 / sum_weights_us_p75 if !missing(sum_weights_us_p75)

* Calculate the deviation and weighted sum of squared deviations for the 75th percentile for Baltimore County, Maryland, and the US
gen deviation_balt_p75 = kfr_pooled_p75 - weight_mean_kfr_balt_p75 if state == 24 & county == 510 & !missing(kfr_pooled_p75)
gen weighted_dev_sq_balt_p75 = deviation_balt_p75^2 * count_pooled if state == 24 & county == 510 & !missing(deviation_balt_p75)
egen total_wdev_sq_balt_p75 = total(weighted_dev_sq_balt_p75) if state == 24 & county == 510

gen deviation_md_p75 = kfr_pooled_p75 - weight_mean_kfr_md_p75 if state == 24 & !missing(kfr_pooled_p75)
gen weighted_dev_sq_md_p75 = deviation_md_p75^2 * count_pooled if state == 24 & !missing(deviation_md_p75)
egen total_wdev_sq_md_p75 = total(weighted_dev_sq_md_p75) if state == 24

gen deviation_us_p75 = kfr_pooled_p75 - weight_mean_kfr_us_p75 if !missing(kfr_pooled_p75)
gen weighted_dev_sq_us_p75 = deviation_us_p75^2 * count_pooled if !missing(deviation_us_p75)
egen total_wdev_sq_us_p75 = total(weighted_dev_sq_us_p75)

* Calculate the total weights and the total weighted sum of squared deviations for the 75th percentile for Baltimore County, Maryland, and the US
sum count_pooled if state == 24 & county == 510
local total_weight_balt_p75 = r(sum)
sum weighted_dev_sq_balt_p75 if state == 24 & county == 510
local total_dev_sq_balt_p75 = r(sum)

sum count_pooled if state == 24
local total_weight_md_p75 = r(sum)
sum weighted_dev_sq_md_p75 if state == 24
local total_dev_sq_md_p75 = r(sum)

sum count_pooled
local total_weight_us_p75 = r(sum)
sum weighted_dev_sq_us_p75
local total_dev_sq_us_p75 = r(sum)

* Calculate the weighted standard deviation for the 75th percentile for Baltimore County, Maryland, and the US
local std_dev_balt_p75 = sqrt(`total_dev_sq_balt_p75' / `total_weight_balt_p75')
local std_dev_md_p75 = sqrt(`total_dev_sq_md_p75' / `total_weight_md_p75')
local std_dev_us_p75 = sqrt(`total_dev_sq_us_p75' / `total_weight_us_p75')

* Display the results
display "Weighted Standard Deviation for Baltimore County at the 75th percentile: " `std_dev_balt_p75'
display "Weighted Standard Deviation for Maryland State at the 75th percentile: " `std_dev_md_p75'
display "Weighted Standard Deviation for U.S. at the 75th percentile: " `std_dev_us_p75'

* Calculate the average downward mobility for children with parents at the 100th percentile (kfr_pooled_p100) in Tract 24510130600, Hampden, Baltimore, MD
sum kfr_pooled_p100 if state == 24 & county == 510 & tract == 130600 [aw = count_pooled ]
local tract_weighted_avg_p100 = r(mean)

* Calculate the population-weighted average of "kfr_pooled_p100" for Maryland
sum kfr_pooled_p100 if state == 24 [aw=count_pooled] 
local weighted_sum_maryland = r(sum)
sum count_pooled if state == 24
local total_count_maryland = r(sum)
local maryland_weighted_avg = `weighted_sum_maryland' / `total_count_maryland'
display "The population-weighted average kfr_pooled_p100 for Maryland is `maryland_weighted_avg'"

* Calculate the population-weighted average of "kfr_pooled_p100" for the entire U.S.
sum kfr_pooled_p100 [aw=count_pooled]
local weighted_sum_us = r(sum)
sum count_pooled
local total_count_us = r(sum)
local us_weighted_avg = `weighted_sum_us' / `total_count_us'

* Display results
display "The population-weighted average kfr_pooled_p100 for Tract 24510130600 is `tract_weighted_avg_p100'"
display "The population-weighted average kfr_pooled_p100 for Maryland is `maryland_weighted_avg'"
display "The population-weighted average kfr_pooled_p100 for the U.S. is `us_weighted_avg'"

* Calculate the weighted kfr for each observation for the 100th percentile
gen weighted_kfr_p100 = kfr_pooled_p100 * count_pooled if !missing(kfr_pooled_p100) & !missing(count_pooled)

* Calculate the weighted mean of kfr for the 100th percentile for Baltimore County, Maryland, and the US
egen sum_weighted_kfr_balt_p100 = total(weighted_kfr_p100) if state == 24 & county == 510
egen sum_weights_balt_p100 = total(count_pooled) if state == 24 & county == 510
gen weight_mean_kfr_balt_p100 = sum_weighted_kfr_balt_p100 / sum_weights_balt_p100 if !missing(sum_weights_balt_p100)

egen sum_weighted_kfr_md_p100 = total(weighted_kfr_p100) if state == 24
egen sum_weights_md_p100 = total(count_pooled) if state == 24
gen weight_mean_kfr_md_p100 = sum_weighted_kfr_md_p100 / sum_weights_md_p100 if !missing(sum_weights_md_p100)

egen sum_weighted_kfr_us_p100 = total(weighted_kfr_p100)
egen sum_weights_us_p100 = total(count_pooled)
gen weight_mean_kfr_us_p100 = sum_weighted_kfr_us_p100 / sum_weights_us_p100 if !missing(sum_weights_us_p100)

* Calculate the deviation and weighted sum of squared deviations for the 100th percentile for Baltimore County, Maryland, and the US
gen deviation_balt_p100 = kfr_pooled_p100 - weight_mean_kfr_balt_p100 if state == 24 & county == 510 & !missing(kfr_pooled_p100)
gen weighted_dev_sq_balt_p100 = deviation_balt_p100^2 * count_pooled if state == 24 & county == 510 & !missing(deviation_balt_p100)
egen total_wdev_sq_balt_p100 = total(weighted_dev_sq_balt_p100) if state == 24 & county == 510

gen deviation_md_p100 = kfr_pooled_p100 - weight_mean_kfr_md_p100 if state == 24 & !missing(kfr_pooled_p100)
gen weighted_dev_sq_md_p100 = deviation_md_p100^2 * count_pooled if state == 24 & !missing(deviation_md_p100)
egen total_wdev_sq_md_p100 = total(weighted_dev_sq_md_p100) if state == 24

gen deviation_us_p100 = kfr_pooled_p100 - weight_mean_kfr_us_p100 if !missing(kfr_pooled_p100)
gen weighted_dev_sq_us_p100 = deviation_us_p100^2 * count_pooled if !missing(deviation_us_p100)
egen total_wdev_sq_us_p100 = total(weighted_dev_sq_us_p100)

* Calculate the total weights and the total weighted sum of squared deviations for the 100th percentile for Baltimore County, Maryland, and the US
sum count_pooled if state == 24 & county == 510
local total_weight_balt_p100 = r(sum)
sum weighted_dev_sq_balt_p100 if state == 24 & county == 510
local total_dev_sq_balt_p100 = r(sum)

sum count_pooled if state == 24
local total_weight_md_p100 = r(sum)
sum weighted_dev_sq_md_p100 if state == 24
local total_dev_sq_md_p100 = r(sum)

sum count_pooled
local total_weight_us_p100 = r(sum)
sum weighted_dev_sq_us_p100
local total_dev_sq_us_p100 = r(sum)

* Calculate the weighted standard deviation for the 100th percentile for Baltimore County, Maryland, and the US
local std_dev_balt_p100 = sqrt(`total_dev_sq_balt_p100' / `total_weight_balt_p100')
local std_dev_md_p100 = sqrt(`total_dev_sq_md_p100' / `total_weight_md_p100')
local std_dev_us_p100 = sqrt(`total_dev_sq_us_p100' / `total_weight_us_p100')

* Display the results
display "Weighted Standard Deviation for Baltimore County at the 100th percentile: " `std_dev_balt_p100'
display "Weighted Standard Deviation for Maryland State at the 100th percentile: " `std_dev_md_p100'
display "Weighted Standard Deviation for U.S. at the 100th percentile: " `std_dev_us_p100'

* Question 6: Regression Analysis & Visualization
* -----------------------------------
* Estimate the relationship between 25th and 75th percentile outcomes

* Regress the dependent variable kfr_pooled_p75 on the independent variable kfr_pooled_p25, using robust standard errors to control for heteroskedasticity
reg kfr_pooled_p75 kfr_pooled_p25, robust

* Generate a scatter plot to visualize the regression
twoway (scatter kfr_pooled_p75 kfr_pooled_p25) (lfit kfr_pooled_p75 kfr_pooled_p25), title("Relationship Between 25th and 75th Percentile Outcomes") xtitle("Children Outcomes at 25th Percentile") ytitle("Children Outcomes at 75th Percentile") legend(label(1 "Data Points") label(2 "Fitted Line"))

* Save the graph
graph export "`datapath'figures_helen/figure2.png", replace

* Question 7: Regression Analysis & Visualization
* -----------------------------------
* Estimate the relationship between 25th and 75th percentile outcomes for white  and black children

* Regression of outcomes at the 75th percentile on outcomes at the 25th percentile for white children
regress kfr_white_p75 kfr_white_p25, robust

* Generate a scatter plot to visualize the regression
twoway (scatter kfr_white_p75 kfr_white_p25) (lfit kfr_white_p75 kfr_white_p25), title("White Children: 25th vs. 75th Percentile Outcomes") xtitle("White Children Outcomes at 25th Percentile") ytitle("White Children Outcomes at 75th Percentile") legend(label(1 "Data Points") label(2 "Fitted Line"))

* Save the graph
graph export "`datapath'figures_helen/figure3.png", replace

* Regression of outcomes at the 75th percentile on outcomes at the 25th percentile for black children
regress kfr_black_p75 kfr_black_p25, robust

* Generate a scatter plot to visualize the regression
twoway (scatter kfr_black_p75 kfr_black_p25) (lfit kfr_black_p75 kfr_black_p25), title("Black Children: 25th vs. 75th Percentile Outcomes") xtitle("Black Children Outcomes at 25th Percentile") ytitle("Black Children Outcomes at 75th Percentile") legend(label(1 "Data Points") label(2 "Fitted Line"))

* Save the graph
graph export "`datapath'figures_helen/figure4.png", replace

* Section 8: Covariate Analysis
* -----------------------------
* Examine covariates and their correlation with upward mobility

* Standardize variables
egen std_kfr_pooled_p25 = std(kfr_pooled_p25)
egen std_kfr_pooled_p75 = std(kfr_pooled_p75)
egen std_rent_twobed2015 = std(rent_twobed2015)
egen std_singleparent_share2010 = std(singleparent_share2010)
egen std_job_density_2013 = std(job_density_2013)

* Regression of 25th percentile outcomes on the rent for a two-bedroom in 2015, the share of single parents in 2010, the job density in 2013
regress std_kfr_pooled_p25 std_rent_twobed2015, robust
regress std_kfr_pooled_p25 std_singleparent_share2010, robust
regress std_kfr_pooled_p25 std_job_density_2013, robust

* Regression of 75th percentile outcomes on the rent for a two-bedroom in 2015, the share of single parents in 2010, the job density in 2013
regress std_kfr_pooled_p75 std_rent_twobed2015, robust
regress std_kfr_pooled_p75 std_singleparent_share2010, robust
regress std_kfr_pooled_p75 std_job_density_2013, robust

* Section 9: Hypothesis Testing
* -----------------------------
* Formulate and test a hypothesis about variation in upward mobility

* Regression of 25th and 75th percentile outcomes on the fraction of residents with a college degree or more in 2010
egen std_frac_coll_plus2010 = std(frac_coll_plus2010)
regress std_kfr_pooled_p25 std_frac_coll_plus2010, robust
regress std_kfr_pooled_p75 std_frac_coll_plus2010, robust

* Cleanup and close
* -----------------------------------

log close
clear all
