
/*******************************************************************************
************    PART 1: Does poverty and food security play a role in   ********
************			adoption of climate smart agriculture?  		********
************			A bivariate probit analysis 		            ********
********************************************************************************
# Name:			Data Management for the above mentioned study

# Purpose:		Estimates a Bivariate Probit Analysis
			
# Creates: 		A pool of estimation tables

# Created by:	Lonjezo Erick Folias, Jan 2025

# Updated by:  	Lonjezo Erick Folias, Jan 2026

# Owner:		(Lonjezo Folias)

# Email  : lonjefolias@hotmail.com

*******************************************************************************/



********************************************************************************
*** Table of Contents
********************************************************************************







********************************************************************************
**# Globals, Macros, Paths, and Ados
********************************************************************************

*Ados

 	local user_commands winsor mkdir  factortest ietoolkit iefieldkit movestay asdoc  codebookout confirmdir zscore06 mpi movestay estat
	  
	foreach command of local user_commands {
		   cap which `command'
		   if _rc == 111 {
			   ssc install `command'
		   }
		   else disp "`command' already installed, moving to the next command line"
	 }
	  
	  
	  
* Project folder : Note ! - make sure the replaced path has / AND not /

	global projectpath C:/Users/wb643670/OneDrive/git/climate ///
	
	cd "$projectpath"

	
*Creating project folders

    local mainfolder `""Data and Do file""'
	
    foreach dir in `mainfolder' {
        confirmdir "`dir'"
        if `r(confirmdir)'==170 {
            mkdir "`dir'"
            display in yellow "Project directory named: `dir' created"
            }
        else disp as error "`dir' already exists. Skipped to next command."
        cd "${projectpath}/`dir'"
    }

	
*Creating subfolders
    local subfolders `" "IHSV" "Working files"  "Do" "Weather Data" "Output""'
	

    foreach dir in `subfolders' {
        confirmdir "`dir'"
        if `r(confirmdir)'==170 {
            mkdir "`dir'"
            disp in yellow "`dir' successfully created."
        }
        else disp as error "`dir' already exists. Skipped to next command."
    }

****NOTE : You need to Manually  Copy the IHSIV data to the "IHSIV" folder 	
**************************************************************************
	
* Path globals
	global data				"${projectpath}/Data and Do file/IHSV"
	global workingfiles		"${projectpath}/Data and Do file/Working files"
	global do 				"${projectpath}/Data and Do file/do"
	global weatherdata 		"${projectpath}/Data and Do file/Weather Data"
	global output	 		"${projectpath}/Data and Do file/Output"

	


* Equation globals
	global poverty_eq		agesq		gender		hh_size		shock 		marital2 marital3	off_farm com_cd71	social_nets		credit 	fisp	
	global foodesecurity_eq	agesq		gender		hh_size		dependency	TLU		shock 		marital2 marital3	off_farm com_cd71	social_nets		credit 	fisp	
	global CSA_eq			agesq		gender		hh_size		extension  	shock    type2 		type3 			type4  	quality2 	quality3
	
	
* Descriptive globals
	global outcome		mpi 	FGT0 		FCS 		HDDS 		rCSI 
	global continous 	age  	hh_size 	TLU 	dependency	
	global categorical 	gender 	marital 	off_farm		extension 	shock 	type  quality  fisp	com_cd71	social_nets		credit
	global all HDDS FCS rCSI FGT0 mpi age hh_size gender dependency extension fisp ///
	TLU type1 type2 type3 type4 quality1 quality2 quality3 marital1 marital2 ///
	marital3 off_farm credit shock social_nets com_cd71
	
	cd "$output" 
	


use  "${workingfiles}/CSA_poverty_foodsecurity_Data.dta", clear

	* Changes to be moved !! to data management do
	g agesq=age*age
	la var agesq "age squared"
	
********************************************************************************
**# Descriptives
********************************************************************************
collect clear 
	
	dtable $outcome $continous $categorical  , by(CSA, tests totals) novarlabel

	local command  "command(  CSA = r(mu_2) sdcsa =  r(sd_2)  Non_CSA= r(mu_1) sdnon_csa =  r(sd_1) (Difference =r(mu_2)-r(mu_1)) pvalue = r(p)"
			
	table (command) (result),   	`command'   : ttest mpi, by(CSA)) 	`command'   : ttest FGT0, by(CSA)) 	`command'   : ttest FCS, by(CSA)) 	`command'   : ttest HDDS, by(CSA)) 	`command'   : 	ttest rCSI, by(CSA)) 	 `command'   : ttest age, by(CSA)) `command'   : ttest hh_size, by(CSA)) `command'   : ttest TLU, by(CSA)) `command'   : ttest gender, by(CSA)) `command'   : ttest marital1, by(CSA))  `command'   : ttest marital2, by(CSA))  `command'   : ttest marital3, by(CSA))  `command'   : ttest off_farm, by(CSA)) `command'   : ttest dependency, by(CSA))  `command'   : ttest extension, by(CSA)) `command'   : ttest shock, by(CSA))  `command'   : ttest type1, by(CSA)) `command'   : ttest type2, by(CSA)) `command'   : ttest type3, by(CSA)) `command'   : ttest type4, by(CSA)) `command'   : ttest quality1, by(CSA)) `command'   : ttest quality2, by(CSA)) `command'   : ttest quality3, by(CSA)) `command'   : ttest fisp, by(CSA)) `command'   : ttest com_cd71, by(CSA)) `command'   : ttest social_nets, by(CSA)) `command'   : ttest credit, by(CSA))
	
	

collect style cell result[CSA sdcsa Non_CSA sdnon_csa Difference ], nformat(%10.2f)
		collect stars pvalue 0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(Difference) 
		*collect layout (colname#result) (model)
		collect style putdocx, layout(autofitcontents)
		collect export Descriptives1.docx, as(docx) replace
		
		
		
	collect clear 
 	
	svyset  case_id , strata( ea_id ) weight( hh_wgt  )
	collect get _r_b _r_se , tag(model[(descriptives)]):   mean  $outcome $continous  $categorical
	collect style cell result[_r_se], nformat(%10.2f) halign(center)
	collect style cell result[_r_b ], nformat(%10.2f) halign(center)
	*collect style cell result[_r_se], sformat("(%s)")
	collect layout (colname) (model#result)
	collect layout   (colname) (cmdset#result[_r_b _r_se])

	collect style cell, nformat(%10.2f)
	collect style putdocx, layout(autofitcontents)
	collect preview
	collect export Descriptives1total.docx, as(docx) replace
	
	collect clear 

					table  ( var) () , statistic(mean $all) statistic(sd $all )  nformat(%9.2fc mean sd )   
					collect preview
					collect style header result, level(hide)
					collect style showbase off
					collect style putdocx, layout(autofitcontents)
					collect export Pooled.docx, as(docx) replace
			
 
********************************************************************************
**# Poverty Model Estimations
********************************************************************************

*Normal Coefficients
 
foreach indicator in  mpi FGT0 {

		collect clear 
		return clear 
		
		biprobit ( CSA = `indicator' $CSA_eq )  (`indicator' = $poverty_eq  ) 
		etable, append  stars( 0.01 "***" 0.05 "**" 0.1 "*" 1  " ", attach(_r_b))          ///
        showstars showstarsnote                                       /// 
        mstat(chi2,   nformat(%8.0fc) label("Chi2"))             ///
		mstat(p,   nformat(%8.4fc) label("P-value"))             ///
		mstat(N,   nformat(%8.0fc) label("N"))             ///
		cstat(_r_b, nformat(%6.3f))    ///
		cstat(_r_se, nformat(%4.2f))    ///
        title("`indicator' : Estimates -Coefficients ")      /// 
        export(`indicator'_Poverty.docx, replace) 
		
		
		
}				

collect clear 

		*dy/dx
		foreach indicator in  mpi FGT0 {

		foreach equation_number in 1 2 {
				biprobit ( CSA = `indicator' $CSA_eq )  (`indicator' = $poverty_eq  ) 
				collect get _r_b _r_p , tag(model[(`indicator'_`equation_number')]): margins, dydx(*) predict(pmarg`equation_number')
		}
			
}				

		collect style cell result[_r_b ], nformat(%6.3f) halign(center)
		collect style cell result[_r_se], sformat("(%s)")
		*collect stars 	_r_p 0.01 "***" 0.05 "**" 0.1 "*" 1  " ", attach(_r_b) 
		collect layout   (colname) (cmdset#result[_r_b])
		collect style      showbase  off
		collect style 	   cell 	border_block, 	border(right, pattern(nil))  
		collect levelsof 	cell_type
		collect style		cell 	cell_type[item column-header], halign(center)
		collect style 		header 	result, level(hide)
		collect style 		row 	stack, spacer delimiter(" x ")
		collect style 		putdocx, layout(autofitcontents)
		collect export 		dydx_poverty.docx, as(docx) replace
		
	ok	
********************************************************************************
**# Food Security Model Estimations
********************************************************************************		
*Normal estimates : Food security
		
collect clear 
		 
foreach indicator in  FCS HDDS rCSI {

		collect clear 
		return clear 
		
		biprobit ( CSA = `indicator' $CSA_eq )  (`indicator' = $foodesecurity_eq  ) 
		etable, append  stars( 0.01 "***" 0.05 "**" 0.1 "*" 1  " ", attach(_r_b))          ///
        showstars showstarsnote                                       /// 
        mstat(chi2,   nformat(%8.0fc) label("Chi2"))             ///
		mstat(p,   nformat(%8.4fc) label("P-valeu"))             ///
		mstat(N,   nformat(%8.0fc) label("N"))             ///
		cstat(_r_b, nformat(%6.3f))    ///
		cstat(_r_se, nformat(%4.2f))    ///
        title("`indicator' : Estimates -Coefficients ")      /// 
        export(`indicator'_foodsecurity.docx, replace) 
		
		
		
}				

collect clear 

		*dy/dx
		foreach indicator in FCS HDDS rCSI  {

		foreach equation_number in 1 2 {
				biprobit ( CSA = `indicator' $CSA_eq )  (`indicator' = $foodesecurity_eq  ) 
				collect get _r_b _r_p , tag(model[(`indicator'_`equation_number')]): margins, dydx(*) predict(pmarg`equation_number')
		}
			
}				

		collect style cell result[_r_b ], nformat(%6.3f) halign(center)
		collect style cell result[_r_se], sformat("(%s)")
		*collect stars 	_r_p 0.01 "***" 0.05 "**" 0.1 "*" 1  " ", attach(_r_b) 
		collect layout   (colname) (cmdset#result[_r_b])
		collect style      showbase  off
		collect style 	   cell 	border_block, 	border(right, pattern(nil))  
		collect levelsof 	cell_type
		collect style		cell 	cell_type[item column-header], halign(center)
		collect style 		header 	result, level(hide)
		collect style 		row 	stack, spacer delimiter(" x ")
		collect style 		putdocx, layout(autofitcontents)
		collect export 		dydx_foodsecurity.docx, as(docx) replace
		
		
		
		