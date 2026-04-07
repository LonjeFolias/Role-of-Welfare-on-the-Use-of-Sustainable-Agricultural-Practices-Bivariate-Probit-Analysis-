
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




*--------------------------------------------------*
* 1. Helper programs
*--------------------------------------------------*
capture program drop _cellfmt
program define _cellfmt, rclass
    args b se p
    local stars ""
    if !missing(`p') {
        if `p' < 0.01 local stars "***"
        else if `p' < 0.05 local stars "**"
        else if `p' < 0.10 local stars "*"
    }
    local bb : display %6.3f `b'
    local ss : display %4.2f `se'
    return local out `"`bb'`stars'`=char(10)'(`ss')"' 
end

capture program drop _cellnum
program define _cellnum, rclass
    args x
    local xx : display %6.3f `x'
    return local out `"`xx'"'
end

*--------------------------------------------------*
* 2. Tempfile for final rows
*--------------------------------------------------*
tempfile final
tempname P

postfile `P' ///
    str30 rowid ///
    str40 rowlabel ///
    str40 mpi_csa_coef ///
    str40 mpi_csa_dydx ///
    str40 mpi_pov_coef ///
    str40 mpi_pov_dydx ///
    str40 fgt_csa_coef ///
    str40 fgt_csa_dydx ///
    str40 fgt_pov_coef ///
    str40 fgt_pov_dydx ///
    double sortorder ///
    using `final', replace

*--------------------------------------------------*
* 3. Row list
*--------------------------------------------------*
local rid1  "mpi"
local lab1  "Poverty"
local rid2  "FGT0"
local lab2  "Poverty"
local rid3  "agesq"
local lab3  "Age squared"
local rid4  "gender"
local lab4  "Gender"
local rid5  "hh_size"
local lab5  "HH_size"
local rid6  "extension"
local lab6  "Extension"
local rid7  "shock"
local lab7  "Shock"
local rid8  "fisp"
local lab8  "Input_prog"
local rid9  "type4"
local lab9  "Loam"
local rid10 "type3"
local lab10 "Clay"
local rid11 "type2"
local lab11 "Other"
local rid12 "quality2"
local lab12 "Good"
local rid13 "quality3"
local lab13 "Poor"
local rid14 "marital2"
local lab14 "Not_married"
local rid15 "marital3"
local lab15 "Widow/er"
local rid16 "off_farm"
local lab16 "Off_farm"
local rid17 "com_cd71"
local lab17 "Mp_visit"
local rid18 "social_nets"
local lab18 "Safety_Net"
local rid19 "credit"
local lab19 "Credit"
local rid20 "_cons"
local lab20 "_cons"
local rid21 "athrho"
local lab21 "Athrho"
local rid22 "rho"
local lab22 "Rho"
local rid23 "chi2"
local lab23 "Χ2"
local rid24 "N"
local lab24 "N"

*--------------------------------------------------*
* 4. MPI model
*--------------------------------------------------*
quietly biprobit ///
    (CSA = mpi $CSA_eq) ///
    (mpi = $poverty_eq)

estimates store MPIModel

scalar mpi_chi2 = e(chi2)
scalar mpi_rho  = e(rho)
scalar mpi_N    = e(N)
scalar mpi_athrho_b  = _b[/athrho]
scalar mpi_athrho_se = _se[/athrho]
scalar mpi_athrho_p  = 2*normal(-abs(_b[/athrho]/_se[/athrho]))

quietly margins, dydx(*) predict(pmarg1)
matrix M1 = r(b)
matrix S1 = r(V)

quietly estimates restore MPIModel
quietly margins, dydx(*) predict(pmarg2)
matrix M2 = r(b)
matrix S2 = r(V)

*--------------------------------------------------*
* 5. FGT0 model
*--------------------------------------------------*
quietly biprobit ///
    (CSA = FGT0 $CSA_eq) ///
    (FGT0 = $poverty_eq)

estimates store FGTModel

scalar fgt_chi2 = e(chi2)
scalar fgt_rho  = e(rho)
scalar fgt_N    = e(N)
scalar fgt_athrho_b  = _b[/athrho]
scalar fgt_athrho_se = _se[/athrho]
scalar fgt_athrho_p  = 2*normal(-abs(_b[/athrho]/_se[/athrho]))

quietly margins, dydx(*) predict(pmarg1)
matrix F1 = r(b)
matrix G1 = r(V)

quietly estimates restore FGTModel
quietly margins, dydx(*) predict(pmarg2)
matrix F2 = r(b)
matrix G2 = r(V)

*--------------------------------------------------*
* 6. Build rows
*--------------------------------------------------*
forvalues i = 1/24 {

    local rowid  = "`rid`i''"
    local rowlab = "`lab`i''"

    local mpi_csa_coef ""
    local mpi_csa_dydx ""
    local mpi_pov_coef ""
    local mpi_pov_dydx ""
    local fgt_csa_coef ""
    local fgt_csa_dydx ""
    local fgt_pov_coef ""
    local fgt_pov_dydx ""

    *----------------------*
    * MPI coefficients
    *----------------------*
    quietly estimates restore MPIModel

    capture scalar b = _b[CSA:`rowid']
    capture scalar s = _se[CSA:`rowid']
    if !_rc {
        scalar p = 2*normal(-abs(b/s))
        quietly _cellfmt b s p
        local mpi_csa_coef `"`r(out)'"'
    }

    capture scalar b = _b[mpi:`rowid']
    capture scalar s = _se[mpi:`rowid']
    if !_rc {
        scalar p = 2*normal(-abs(b/s))
        quietly _cellfmt b s p
        local mpi_pov_coef `"`r(out)'"'
    }

    * MPI pmarg1
    local k = colnumb(M1, "`rowid'")
    if `k' < . {
        capture scalar c = M1[1, `k']
        capture scalar s = sqrt(S1[`k', `k'])
        if !_rc {
            scalar p = 2*normal(-abs(c/s))
            quietly _cellfmt c s p
            local mpi_csa_dydx `"`r(out)'"'
        }
    }

    * MPI pmarg2
    local k = colnumb(M2, "`rowid'")
    if `k' < . {
        capture scalar c = M2[1, `k']
        capture scalar s = sqrt(S2[`k', `k'])
        if !_rc {
            scalar p = 2*normal(-abs(c/s))
            quietly _cellfmt c s p
            local mpi_pov_dydx `"`r(out)'"'
        }
    }

    *----------------------*
    * FGT0 coefficients
    *----------------------*
    quietly estimates restore FGTModel

    capture scalar b = _b[CSA:`rowid']
    capture scalar s = _se[CSA:`rowid']
    if !_rc {
        scalar p = 2*normal(-abs(b/s))
        quietly _cellfmt b s p
        local fgt_csa_coef `"`r(out)'"'
    }

    capture scalar b = _b[FGT0:`rowid']
    capture scalar s = _se[FGT0:`rowid']
    if !_rc {
        scalar p = 2*normal(-abs(b/s))
        quietly _cellfmt b s p
        local fgt_pov_coef `"`r(out)'"'
    }

    * FGT0 pmarg1
    local k = colnumb(F1, "`rowid'")
    if `k' < . {
        capture scalar c = F1[1, `k']
        capture scalar s = sqrt(G1[`k', `k'])
        if !_rc {
            scalar p = 2*normal(-abs(c/s))
            quietly _cellfmt c s p
            local fgt_csa_dydx `"`r(out)'"'
        }
    }

    * FGT0 pmarg2
    local k = colnumb(F2, "`rowid'")
    if `k' < . {
        capture scalar c = F2[1, `k']
        capture scalar s = sqrt(G2[`k', `k'])
        if !_rc {
            scalar p = 2*normal(-abs(c/s))
            quietly _cellfmt c s p
            local fgt_pov_dydx `"`r(out)'"'
        }
    }

    *----------------------*
    * Bottom rows
    *----------------------*
    if "`rowid'" == "athrho" {
        quietly _cellfmt mpi_athrho_b mpi_athrho_se mpi_athrho_p
        local mpi_csa_coef `"`r(out)'"'
        quietly _cellfmt fgt_athrho_b fgt_athrho_se fgt_athrho_p
        local fgt_csa_coef `"`r(out)'"'
    }

    if "`rowid'" == "rho" {
        quietly _cellnum mpi_rho
        local mpi_csa_coef `"`r(out)'"'
        quietly _cellnum fgt_rho
        local fgt_csa_coef `"`r(out)'"'
    }

    if "`rowid'" == "chi2" {
        local mpi_csa_coef : display %9.0f mpi_chi2
        local fgt_csa_coef : display %9.0f fgt_chi2
    }

    if "`rowid'" == "N" {
        local mpi_csa_coef : display %9.0f mpi_N
        local fgt_csa_coef : display %9.0f fgt_N
    }

    post `P' ///
        ("`rowid'") ///
        ("`rowlab'") ///
        (`"`mpi_csa_coef'"') ///
        (`"`mpi_csa_dydx'"') ///
        (`"`mpi_pov_coef'"') ///
        (`"`mpi_pov_dydx'"') ///
        (`"`fgt_csa_coef'"') ///
        (`"`fgt_csa_dydx'"') ///
        (`"`fgt_pov_coef'"') ///
        (`"`fgt_pov_dydx'"') ///
        (`i')
}

postclose `P'

use `final', clear
sort sortorder

*--------------------------------------------------*
* 7. Export one Word file
*--------------------------------------------------*
putdocx clear
putdocx begin, font("Times New Roman", 10) pagesize(A4)

putdocx paragraph, halign(center)
putdocx text ("Table 5. Seemingly unrelated bivariate probit estimations for poverty."), bold

putdocx paragraph
putdocx text ("Standard errors in parentheses. *** p<0.01, ** p<0.05, * p<0.10."), italic

* 24 body rows + 2 header rows
local nrows = 26

putdocx table tbl = (`nrows', 9)

* Header row 1
putdocx table tbl(1,1) = ("Predictor"), bold halign(center)
putdocx table tbl(1,2) = ("MPI: CSA"), bold halign(center)
putdocx table tbl(1,3) = ("MPI: CSA"), bold halign(center)
putdocx table tbl(1,4) = ("MPI: MPI"), bold halign(center)
putdocx table tbl(1,5) = ("MPI: MPI"), bold halign(center)
putdocx table tbl(1,6) = ("PHC: CSA"), bold halign(center)
putdocx table tbl(1,7) = ("PHC: CSA"), bold halign(center)
putdocx table tbl(1,8) = ("PHC: Poverty"), bold halign(center)
putdocx table tbl(1,9) = ("PHC: Poverty"), bold halign(center)

* Header row 2
putdocx table tbl(2,2) = ("Coeff."), bold halign(center)
putdocx table tbl(2,3) = ("Dy/dx"), bold halign(center)
putdocx table tbl(2,4) = ("Coeff."), bold halign(center)
putdocx table tbl(2,5) = ("Dy/dx"), bold halign(center)
putdocx table tbl(2,6) = ("Coeff."), bold halign(center)
putdocx table tbl(2,7) = ("Dy/dx"), bold halign(center)
putdocx table tbl(2,8) = ("Coeff."), bold halign(center)
putdocx table tbl(2,9) = ("Dy/dx"), bold halign(center)

* Body
forvalues i = 1/24 {
    local r = `i' + 2
    putdocx table tbl(`r',1) = (rowlabel[`i'])
    putdocx table tbl(`r',2) = (mpi_csa_coef[`i']), halign(center)
    putdocx table tbl(`r',3) = (mpi_csa_dydx[`i']), halign(center)
    putdocx table tbl(`r',4) = (mpi_pov_coef[`i']), halign(center)
    putdocx table tbl(`r',5) = (mpi_pov_dydx[`i']), halign(center)
    putdocx table tbl(`r',6) = (fgt_csa_coef[`i']), halign(center)
    putdocx table tbl(`r',7) = (fgt_csa_dydx[`i']), halign(center)
    putdocx table tbl(`r',8) = (fgt_pov_coef[`i']), halign(center)
    putdocx table tbl(`r',9) = (fgt_pov_dydx[`i']), halign(center)
}

putdocx table tbl(.,.), border(all, nil)
putdocx table tbl(1,.), border(top, single)
putdocx table tbl(2,.), border(bottom, single)
putdocx table tbl(26,.), border(bottom, single)
putdocx table tbl(.,1), halign(left)

putdocx save "Table5_poverty_final.docx", replace

display as result "Created: Table5_poverty_final.docx"

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
		
		
		
		