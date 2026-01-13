/*******************************************************************************
************    PART 6: Does poverty and food security play a role in   ********
************			adoption of climate smart agriculture?  		********
************			A bivariate probit analysis 		            ********
********************************************************************************
# Name:			Post estimation tests

# Purpose:		Tests econometric and theory assumptions after model estimations
			
# Updated by:  	Lonjezo Erick Folias, Jan 2025

# Owner:		(Lonjezo Folias)

# Email  : lonjefolias@hotmail.com

*******************************************************************************/



********************************************************************************
*** Table of Contents
********************************************************************************







********************************************************************************
**# Globals, Macros, Paths, and Ados
********************************************************************************
* Equation globals
	global poverty_eq		agesq		gender		hh_size		shock 		marital2 marital3	off_farm com_cd71	social_nets		credit 	fisp	
	global foodesecurity_eq	agesq		gender		hh_size		dependency	TLU		shock 		marital2 marital3	off_farm com_cd71	social_nets		credit 	fisp	
	global CSA_eq			agesq		gender		hh_size		extension  	shock   fisp  		type2 		type3 			type4  	quality2 	quality3
	
	
use  "${workingfiles}/CSA_poverty_foodsecurity_Data.dta", clear

	* Changes to be moved !! to data management do
	g agesq=age*age
	la var agesq "age squared"


biprobit (CSA= FCS $CSA_eq ) (FCS = $poverty_eq  ) 
estat ovtest