/*******************************************************************************
************    PART 1: Does poverty and food security play a role in   ********
************			adoption of climate smart agriculture?  		********
************			A bivariate probit analysis 		            ********
********************************************************************************
# Name:			Data Management for the above mentioned study

# Purpose:		Generates variables (dataset) for the above mentioned study
			
# Creates: 		CSA_poverty_foodsecurity.dta

# Created by:	Lonjezo Erick Folias, Jan 2025

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

*Ados

 	local user_commands winsor mkdir  factortest ietoolkit iefieldkit movestay asdoc  codebookout confirmdir zscore06 mpi switch_probit movestay bicop
	  
	foreach command of local user_commands {
		   cap which `command'
		   if _rc == 111 {
			   ssc install `command'
		   }
		   else disp "`command' already installed, moving to the next command line"
	 }
	  
	  
	  
* Project folder : Note ! - make sure the replaced path has / AND not \

	global projectpath C:/Users/Lonje Folias/Documents/Manu Scripts/Climate 
	
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
    local subfolders `" "IHSV" "Working files"  "Do" "Weather Data" "'
	

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
	
	
	global deprivations dep_educ_1 dep_educ_2 dep_health_1 dep_health_2 dep_health_3 dep_health_4 dep_env1 dep_env2 dep_env3 dep_empl_1 dep_empl_2 dep_empl_3 dep_env4
	 
********************************************************************************
**# Survey Data Management
********************************************************************************



	
use "${data}/hh_mod_b.dta", clear 
		
		*merging with pertinent modules 
		merge 1:1 	case_id  PID 	using 	"${data}/hh_mod_c.dta", 		nogen 
		merge m:1 	case_id  		using 	"${data}/hh_mod_a_filt.dta", 	nogen 
		merge m:1 	case_id	 	  	using 	"${data}/hh_mod_f.dta", 		nogen 
		merge 1:1 	case_id  PID 	using 	"${data}/hh_mod_v.dta", 		nogen 
		merge 1:1 	case_id  PID 	using 	"${data}/hh_mod_e.dta", 		nogen 
		merge m:1 	case_id  	 	using 	"${workingfiles}/asset.dta", 	nogen 
		merge m:1 	case_id  	 	using 	"${data}/hh_mod_a_filt.dta", 	nogen		
		merge m:1 	case_id			using	"${data}/hh_mod_t.dta", 		nogen 
		merge m:1 	case_id			using	"${data}/householdgeovariables_ihs5.dta", 		nogen 

	
		********************************************************************************
	**# HH demo vars
		********************************************************************************
		
		*Age
		bysort 		case_id: g  	age=hh_b05a 		if 	hh_b04==1 

		*Dependancy ratio		
		bysort 	case_id: 	egen 	a=count(PID) 		if  hh_b05a<=14  | hh_b05a>64
		bysort 	case_id: 	egen	dependants=max(a) 	
		
		bysort 	case_id: 	egen 	b=count(PID) 		if 	hh_b05a>14	 & hh_b05a<=64
		bysort 	case_id: 	egen	working=max(b) 
		
		recode	 dependants (.=0)	
		recode 	 working	(.=1)
		
		g	 	 dependency=(dependants/working)
		
		*HH_Size
		bysort 	 case_id: 	 egen 	hh_size=count(PID)

		*Alduts
		bysort  case_id: 	 egen   alduts=count(PID) 	if hh_b05a>=15
		
		*Maritial 
		bysort case_id: 	 g  	marital=hh_b24 		if hh_b04==1
		
		
		*Gender
		bysort case_id: 	 g  	gender=hh_b03 		if hh_b04==1
		
		*Years in the Village
		bysort case_id: 	 g  	years_village=hh_b12 if hh_b04==1
		replace years_village=age 	if  missing( hh_b12 )
		
		*Education
		bysort case_id: g  educ=hh_c08 if hh_b04==1
		
		********************************************************************************
	**# HH MPI Indictors 
		********************************************************************************
		
*Education
			
			/*A household is deprived if all members aged 15+ have
			*less than 8 years of schooling OR cannot read or write
			English or Chichewa
			
			There is no variable asking the exact years spend on education
			Therefore, I make the strong assumption that getting to STD 8 
			is above the above defined assumption*/
			
			
			g 		lessstd8=1		if		((hh_b05a>=15)		& 	(hh_c08<8))
			g 		cannotread=1	if 		((hh_b05a>=15)		& 	(hh_c05_1==2))
			g 		deped=1 		if 		lessstd8==1			| 	cannotread==1
			
			
			// counting the above created conditions per HH
			bysort		case_id:	egen hh_15_counta=count(PID)		if 	hh_b05a>=15
			bysort		case_id:	egen depedcounta=count(PID)			if 	deped==1 	
			
			foreach 	var 	in 	hh_15_count depedcount {
				bysort	case_id:	egen `var'=count(`var'a)
			}
			
			bysort 		case_id:	g	 dep_educ_1=1 	if		hh_15_count==depedcount 
		
		
			/*A household is deprived if at least one child aged 6–14 is
			not attending school*/
			g 		attendance=1 	if 	((inrange(hh_b05a, 6, 14)) & hh_c13==2)
			bysort 		case_id:	egen	 dep_educ_2=max(attendance) 
			
			
*Health and Population

			/*A household is deprived if the sanitation facility is not
			flush or a VIP latrine or a latrine with a roof OR if it is
			shared with other households*/
			
			g		  latrine=1 	if 	(inrange(hh_f41, 8, 13)) | hh_f41_4==1
			bysort 		case_id:	egen	 dep_health_1=max(latrine) 
			
			
			/*A household is deprived if there is at least one child
			under 5 who is either underweight, stunted, or wasted*/
			
			gen 	 agemonths =hh_b05b     if hh_b05a ==0
			replace  agemonths =hh_b05b +12 if hh_b05a ==1
			replace  agemonths =hh_b05b +24 if hh_b05a ==2
			replace  agemonths =hh_b05b +36 if hh_b05a ==3
			replace  agemonths =hh_b05b +48 if hh_b05a ==4

						
			*** Create child age-group dummies

			* 0-23 months
			gen 	age_0_23m = (agemonths <= 23)        if hh_b05a <18

			* 24-59 months
			gen 	age_24_59m= inrange(agemonths,24,59) if hh_b05a <18
			
			* Generate z-scores for stunting, underweight and wasting for children under 5
			* using 'zscore06' the 2006 WHO child growth standards 
		

			* Age of child in months, a()
			sum      agemonths

			* Sex of child, s() where 1 is male and 2 is female
			tab      hh_b03

			* Height/length of child, h() in cm 
			*	Recumbent length is assumed for children <24months 
			*	While standing height for children >24 months. If not, measure() must be 
			*   specified 1 for recumbent length and 2 for standing height 

	
			tab      hh_v10 if hh_b05a <5, m
			gen 	 measure = cond(hh_v10<2,2,1) if hh_b05a <5 & !missing(hh_v10)

			* Treating missing 'measure', assuming recumbent length for 0-23 months and
			*    standing height for 24-59 months
			tab      measure if hh_b05a <5, m
			replace  measure = 1 if age_0_23m == 1 & missing(hh_v10) 
			replace  measure = 2 if age_24_59m== 1 & missing(hh_v10)
			tab      measure	

			* Check the variables for missing observations
			count if (hh_b03==. | hh_v09==. | hh_v08==. | measure==.) & hh_b05a<5

			//Expecting to have some cases with missing zscores

			zscore06, a(agemonths) s(hh_b03) h(hh_v09) w(hh_v08) measure(measure)

			* Check missing zscores 
			count if haz06==. & hh_b05a <5
			count if waz06==. & hh_b05a <5
			count if whz06==. & hh_b05a <5
			   
			* ------------------------------------------------------------------------------
			*** Indicator i) Stunted

			* Deprived if height for age < -2 standard deviations (s.d.) (24-59 months)
			* ------------------------------------------------------------------------------

			gen 	ind_stunted =   (haz06 <-2) if age_24_59m ==1
			replace ind_stunted = . if haz06==. &  age_24_59m ==1

			* ------------------------------------------------------------------------------
			*** Indicator ii) Underweight

			* Deprived if Weight for age <-2 s.d. (0-23 months)
			* ------------------------------------------------------------------------------

			gen     ind_underweight =   (waz06 <-2) if age_0_23m ==1
			replace ind_underweight = . if waz06==. &  age_0_23m ==1

			* ------------------------------------------------------------------------------
			*** Indicator iii) Wasting

			* Deprived if weight for height <-2 s.d. (0-23 months)
			* ------------------------------------------------------------------------------

			gen      ind_wasting =   (whz06 <-2) if age_0_23m ==1
			replace  ind_wasting = . if whz06==. &  age_0_23m ==1
			* ------------------------------------------------------------------------------
						
			foreach ind in stunted underweight wasting {
				bysort 		case_id:	egen	 	`ind'=max(ind_`ind') 
			}
			
			gen 	dep_health_2=1 	if  stunted==1  | underweight==1  |  wasting==1
			
			/*A household is deprived if their main source of water is
			unimproved OR it takes 30 minutes or more (round trip)
			to collect it*/
			
			gen      	watersource= 		inlist(hh_f36,4,5,10,11,12,16,18) 
			
			foreach  string in PIPED TAP PROTECTED {
				replace watersource=. if regexm(hh_f36_oth,"`string'")
			}
			 
			replace 	watersource=1 	if 	hh_f38a>30 	& hh_f38b==1
			replace 	watersource=1 	if 	hh_f38a>1 	& hh_f38b==2
			
			bysort 		case_id:	egen	 	dep_health_3=max(watersource)
			
			
			/*A household is deprived if, in the past 12 months, they
			were hungry but did not eat AND went without eating for
			a whole day because there was not enough money or
			other resources for food*/
			
			gen      hunger= inlist( hh_t19 ,2)
			
			bysort 		case_id:	egen	 	dep_health_4=max(hunger)
			
			
			
*ENV			
			/*A household is deprived if they do not have access to
			electricity*/
			
			bysort 		case_id:	egen 		electricity=max(hh_f19) 	
			bysort 		case_id:	g			dep_env1=1 		if inlist(electricity,1)
			
			/*A household is deprived if rubbish is disposed of on a
			public heap, is burnt, disposed of by other means, or there
			is no disposal*/
			
			gen      	dep_env2= 		inlist(hh_f43,3,4,5,6) 
			
			foreach string in DISPOS SERVICE {
				replace dep_env2=. 	if	regexm(hh_f43_oth,"`string'")
			}
			
			
			/* A household is deprived if at least two of the following
			dwelling structural components are of poor quality:
				•Walls (grass, mud, compacted earth, unfired mud
				bricks, wood, iron sheets, or other materials)
				•Roof (grass, plastic sheeting, or other materials)
				•Floor (sand, smoothed mud, wood, or other materials)*/
			
			gen      	wall= 		inlist(hh_f07,1,2,3,4,7,8,9) 
			
			foreach string in CONC GLA {
				replace wall=. 	if	regexm(hh_f07_oth,"`string'")
			}
			
			
			gen      	roof= 		inlist(hh_f08,1,5,6) 
			
			foreach string in LEEDS TILES  {
				replace roof=. 	if	regexm(hh_f08_oth,"`string'")
			}
			
			gen      	floor= 		inlist(hh_f09,1,2,4,6)
			
			foreach string in CEME CONC  {
				replace floor=. 	if	regexm(hh_f09_oth,"`string'")
			}
			
			egen		agrigate=rowtotal(wall roof floor )
			
			bysort 		case_id:	g			dep_env3=1 		if agrigate>=2 
			
			
			g 		asset_1dummy=1 	if 	hh_b04a==1
			egen	asset_1=max(asset_1dummy),by(case_id)
			
			
*Employment (1/4)		

			/*A household is deprived if at least one member aged
			18–64 has not been working but has been looking for a
			job during the past 4 weeks*/
			
			g 		unempllookingfor=1		if 	(hh_e06_2==2  	| 	hh_e06_4==2	)	& 	hh_e17_1==1 & inrange(hh_b05a,18,64)

			egen 	dep_empl_1=max(unempllookingfor), 	by(case_id)
			
			/*A household is deprived if all working members are only
			engaged in farm activities, household livestock activities,
			or casual part-time work (ganyu)*/
			
			g 		ganyu=1 	if	(hh_e06_6==1 	| 	hh_e06_1a==1  |	hh_e06_1b==1 | inlist(hh_e06_8a,3,5))	& inrange(hh_b05a,18,64)
			replace ganyu=. 	if 	hh_e06_2==1  	| 	hh_e06_4==1	  | inlist(hh_e06_8a,1,2)
			
			egen 	workinga=count(PID)		if 		inrange(hh_b05a,18,64), 	by(case_id)
			egen 	wcount=	max(workinga)	, 	by(case_id)
			egen 	gcount=count(ganyu)		, 	by(case_id)
			
			g 		equal=1 	if 	wcount==gcount & !missing(wcount)
			
			egen  	dep_empl_2=max(equal)	, by(case_id)
			
			/*A household is deprived if any child aged 5–17 is
			engaged in any economic activities in or outside of the
			household*/
			g		ylabor=1 if (inlist(hh_e06_8a,1,2,5)	|	hh_e06_2==1	|	hh_e06_4==1	|	hh_e06_6==1	)	 & inrange(hh_b05a,5,17)
			
			egen  	dep_empl_3=max(ylabor)	, by(case_id)
			
			

			/*A household is deprived if they do not own more than
			two of the following basic livelihood items: radio,
			television, telephone, computer, animal cart, bicycle,
			motorbike, or refrigerator AND do not own a car or truck*/
			
			egen assets=rowtotal(assest_507 assest_5081 assest_509 assest_529 assest_516 assest_517 assest_514  assest_609 assest_610 assest_613 asset_1)
			
			g	 dummy=1	if	 assets>2 | car==1

			bysort 		case_id:	egen	 	dep_env4=max(dummy)
			
			
			
			/* Geo cordinates*/
			rename ( ea_lon_mod ea_lat_mod ) (lon lat)


			
			collapse (firstnm)  HHID ea_id (max) age hh_size alduts years_village marital dependency gender dep_* reside region district  hh_wgt hh_a02a lon lat educ, by (case_id)
		
			foreach var in dep_*{
				recode `var' (.=0)
			}

			********************************************************************************
*** Define vector 'w' of dimensional and indicator weight ***
********************************************************************************

*Health and Population / env

foreach health in dep_health_1 dep_health_2 dep_health_3 dep_health_4  dep_env1 dep_env2 dep_env3 dep_env4{
	gen w_`health' = 1/16
	}

*Education 
foreach educ in dep_educ_1 dep_educ_2 {
	gen w_`educ' = 1/8
	}

*Employment 
foreach empl in dep_empl_1 dep_empl_2 dep_empl_3 {
	gen w_`empl' = 1/12
	}

********************************************************************************
*** Generate the weighted deprivation matrix 'w' * 'g0'
********************************************************************************

foreach var of global deprivations {
	g weighted_`var'=w_`var' * `var'
}

********************************************************************************
*** Generate the vector of individual weighted deprivation count 'c'
********************************************************************************
egen	total_deprivations = rowtotal( weighted_dep_health_1 weighted_dep_health_2 weighted_dep_health_3 weighted_dep_health_4 weighted_dep_env1 weighted_dep_env2 weighted_dep_env3 weighted_dep_env4 weighted_dep_educ_1 weighted_dep_educ_2 weighted_dep_empl_1 weighted_dep_empl_2 weighted_dep_empl_3)


********************************************************************************
*** Identification step according to poverty cutoff k (33.33 ) ***
********************************************************************************
gen	mpi= (total_deprivations>=33/100)

			mpi d1(dep_health_1 dep_health_2 dep_health_3 dep_health_4) d2( dep_educ_1 dep_educ_2) d3(dep_env1 dep_env2 dep_env3 dep_env4) d4(dep_empl_1 dep_empl_2 dep_empl_3) w1(0.0625 0.0625 0.0625 0.0625) w2(0.125 0.125) w3(0.0625 0.0625 0.0625 0.0625) w4(0.0833333333333333 0.0833333333333333 0.0833333333333333), cutoff(0.33)
	
	drop w_* weighted_* total_deprivations 
	
save  "${workingfiles}/a.dta", replace 


	********************************************************************************
	**# Climatic Shock	
	********************************************************************************

use "${data}/hh_mod_u.dta", clear

		g 		drought=1 			if 	hh_u0a==101 	& 	hh_u01==1
		g 		floods=1 			if 	hh_u0a==102 	& 	hh_u01==1
		g 		irregularrains=1 	if 	hh_u0a==1101 	& 	hh_u01==1	
		
		collapse (max) drought floods irregularrains, by (case_id)
		
		merge 1:1 case_id using "${workingfiles}/a.dta", nogen
	
save  "${workingfiles}/b.dta", replace 	
	


	********************************************************************************
	**# Community level Networking
	********************************************************************************

		use "${data}/com_cd.dta" 
		
		keep ea_id com_cd70 com_cd71
		
		merge 1:m ea_id using "${workingfiles}/b.dta", nogen
		
save  "${workingfiles}/c.dta", replace 	


	********************************************************************************
	**# Food Security Indicators 
	********************************************************************************

	
*rCSI

 
     cap u "${data}/hh_mod_h.dta", clear 
	 
		foreach indicator in  hh_h02a  hh_h02e  hh_h02c hh_h02b  hh_h02d { // maximum days per week is 7
			replace 	`indicator'=7 	if 	`indicator'>7
		}
		
		gen 	 CSI=( hh_h02a *1) + ( hh_h02e *2) + ( hh_h02c *1) + ( hh_h02b *1) + ( hh_h02d *3)

		
		
		keep 		CSI case_id 
		
		collapse 	(max)   CSI ,by(case_id)

		merge 1:1 	case_id using  "${workingfiles}/c.dta", nogen
		
save  "${workingfiles}/c.dta", replace 			
	 
	 
use "${data}/HH_MOD_G2.dta", clear
		
		
*FCS

replace hh_g08a=hh_g08b if hh_g08a<hh_g08b & !missing(hh_g08b)

		foreach i in a  c d e f g h i  {
			g fs`i'=.
		}
		
		//cereal 
		replace fsa=hh_g08a*2 
		
		// pulses
		replace fsc=hh_g08c*3 
		
		// Meat and milk
		foreach v in e g  { 
			replace fs`v'=hh_g08`v'*4 
		}
		
		// Veggies and Fruits
		foreach i in d f   { 
			replace fs`i'=hh_g08`i'*1 
		}
		
		 // Sugar + oil 
		foreach i in h i    {
			replace fs`i'=hh_g08`i'*0.5
		}
	
		egen fcs=rowtotal(fs*)
		
		//ordinal fcs
		gen fcsa=. 
		replace fcsa=1 if fcs<21
		replace fcsa=2 if fcs>=21 &   fcs<=35
		replace fcsa=3 if fcs>35

		
		
*HDDS
		foreach 	letter 	in 	a  	b 	c 	d 	e 	f 	g 	h 	i 	j {
					g		hd_`letter'=. 
					replace hd_`letter'=1 	if 	hh_g08`letter'>0
					recode 	hd_`letter' (.=0)
		}
		
		egen  		HDDS	=rowtotal(hd_*)
		
		keep 		case_id fcsa fcs	HDDS 
		
		merge 1:1 	case_id using  "${workingfiles}/c.dta", nogen
		

save   "${workingfiles}/d.dta", replace 	



	********************************************************************************
	**# Climate Variables 
	********************************************************************************	
		
	
			use "${data}/householdgeovariables_ihs5.dta", clear 

			keep case_id af_bio_1_x af_bio_12_x    
			
			replace af_bio_1_x=af_bio_1_x/10 
			
			merge 1:1 case_id using "${workingfiles}/d.dta", nogen
			
save  "${workingfiles}/e.dta", replace 

	********************************************************************************
	**# Expenditure
	********************************************************************************	
	
	do "${do}/expenditure.do" 


	********************************************************************************
	**# Climate Variables 
	********************************************************************************	
use "${data}/HH_MOD_N2.dta", clear

		g off_farm=1 if hh_n09a!=.
		keep  HHID  off_farm
		collapse (max) off_farm , by (HHID)
		
		merge 1:1 HHID using "${workingfiles}/e.dta", nogen
		
save  "${workingfiles}/off_farm.dta", replace 	
	
	
	********************************************************************************
	**# Credit
	********************************************************************************

use "${data}/hh_mod_s1.dta", clear				
		
		keep if hh_s01==1
		
		duplicates drop case_id, force
		
		keep hh_s01 case_id
 
	
		merge 1:1 case_id using "${workingfiles}/exp_o.dta", nogen
		merge 1:1 case_id using "${workingfiles}/off_farm.dta", nogen
		
save  "${workingfiles}/f.dta", replace 	


********************************************************************************
	**# Extension Services
********************************************************************************	

use "${data}/ag_mod_t1.dta" , clear 

		keep if ag_t01==1
		
		keep case_id ag_t01
		
		collapse (max) ag_t01 , by (case_id)
		
		merge 1:1 case_id using "${workingfiles}/f.dta", nogen	
		
save  "${workingfiles}/g.dta", replace 		


********************************************************************************
	**# Input Subsidy
********************************************************************************

use "${data}/ag_mod_e2.dta" , clear 

		keep if ag_e01==1
		
		keep case_id ag_e01
		
		collapse (max) ag_e01 , by (case_id)
		
		merge 1:1 case_id using "${workingfiles}/g.dta", nogen	
		
save  "${workingfiles}/hh_data.dta", replace 		


* The next modules will require managament at plot level. Therefore, we shall keep the household data on hold for now.

********************************************************************************
	**# Land Size
********************************************************************************

use "${data}/ag_mod_c.dta" , clear

		keep case_id gardenid plotid ag_c04a ag_c04b ag_c04c ag_c04b_oth
		
		replace ag_c04a=ag_c04a*2.4711 if ag_c04b==2
		replace ag_c04a=ag_c04a*000024710538146717 if ag_c04b==3
		replace ag_c04a=ag_c04a*0.0002066115903 if ag_c04b_oth=="YARDS"
		replace ag_c04a=ag_c04a*000024710538146717 if ag_c04b_oth=="METERS"
		replace ag_c04c=ag_c04b if ag_c04c==. | ag_c04c==0
 
		keep case_id gardenid plotid ag_c04c
		
save  "${workingfiles}/h.dta", replace 
		
********************************************************************************
	**# TLU 
*******************************************************************************
use "${data}/ag_mod_r1.dta" , clear
		keep ag_r0a case_id ag_r01 ag_r02
		g TLU=.
		
		foreach i in 301 302 303 304 318 3304  {
			replace TLU=ag_r02*1 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 307 308 {
			replace TLU=ag_r02*0.1 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 309 3314 {
			replace TLU=ag_r02*0.2 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 311 313  {
			replace TLU=ag_r02*0.01 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 315  {
			replace TLU=ag_r02*0.03 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 319  {
			replace TLU=ag_r02*0.01 if ag_r0a==`i' & ag_r01==1
		}
		
		foreach i in 3305    {
			replace TLU=ag_r02*0.7 if ag_r0a==`i' & ag_r01==1
		}
		
		
		foreach v of varlist  TLU {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			*replace `v'=m_`v' if `v'<50
			replace `v'=m_`v' if z_`v'>3
			replace `v'=m_`v' if z_`v'<-0.1
}
		drop z_* a_* m_*
		
				
		foreach v of varlist  TLU {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			*replace `v'=m_`v' if `v'<50
			replace `v'=m_`v' if z_`v'>3
			replace `v'=m_`v' if z_`v'<-0.1
}
		drop z_* a_* m_*
		
		keep TLU case_id 
		
		collapse (sum) TLU , by(case_id)
		
		merge 1:m case_id  using "${workingfiles}/h.dta", nogen
		
save  "${workingfiles}/i.dta", replace 	

********************************************************************************
	**# Social Seft Nets
*******************************************************************************

use "${data}/hh_mod_r.dta", clear 
	
	g social_nets=1 if hh_r01==1
	
	keep social_nets case_id 
		
	collapse (max) social_nets   , by(case_id)
	
	merge 1:m case_id  using "${workingfiles}/i.dta", nogen
		
save  "${workingfiles}/i.dta", replace 

********************************************************************************
	**# Plot Level details 
*******************************************************************************

use "${data}/ag_mod_d.dta" , clear

		g maize=.
		foreach v of varlist ag_d20a ag_d20b ag_d20c ag_d20d ag_d20e {
		replace maize=1 if `v'<=4
		}
		g type= ag_d21 if maize==1
		g quality= ag_d22 if maize==1
		rename ag_d36  organic_fertilizer
		rename ag_d38  inorganic_fertilizer
		rename ag_d55_1  agro_forestry
		g box_ridges=1 if ag_d62==2
		g minimum_tillage=1 if ag_d62==6
		g traditional_tilage=1 if ag_d62==1
		g plating_pits=1 if ag_d62==3
		
		
		foreach i in erosion_control_bunds vetiver Terraces Water_harvest_bunds  {
			g `i'=.
		}
		
		foreach i in a b  {
			replace erosion_control_bunds=1 if ag_d25`i'==3
			replace vetiver=1 if ag_d25`i'==5
			replace Terraces=1 if ag_d25`i'==2
			replace Water_harvest_bunds=1 if ag_d25`i'==7
			
		}
		
		
		keep case_id gardenid plotid maize type quality inorganic_fertilizer organic_fertilizer agro_forestry erosion_control_bunds vetiver box_ridges minimum_tillage plating_pits traditional_tilage Terraces Water_harvest_bunds 
		
		merge 1:1 case_id gardenid plotid using "${workingfiles}/i.dta", nogen


		collapse (sum) ag_c04c (max) social_nets  TLU plating_pits traditional_tilage Terraces Water_harvest_bunds organic_fertilizer agro_forestry inorganic_fertilizer maize type quality erosion_control_bunds vetiver box_ridges minimum_tillage , by (case_id)
		
save  "${workingfiles}/j.dta", replace 	
	
		merge 1:1 case_id  using "${workingfiles}/hh_data.dta", nogen	

		
********************************************************************************
	**# Constructing indicators
********************************************************************************
		g CSA=.
	/*
	foreach i in box_ridges erosion_control_bunds vetiver plating_pits Terraces Water_harvest_bunds agro_forestry {
		replace CSA=1 if inlist(`i',1)
		recode `i' (.=0)
	}
		*/
		
	foreach i in box_ridges erosion_control_bunds vetiver plating_pits Terraces Water_harvest_bunds  {
		replace CSA=1 if inlist(`i',1)
		recode `i' (.=0)
	}
	

		foreach i of varlist CSA {
			
			clonevar x_`i'=`i'
			recode x_`i' (0=.)
			bysort district : egen a_`i'=count(x_`i')
			bysort district : egen b_`i'=count(district)
			g IV_`i'=a_`i'/b_`i'

		}
			
		drop x_* a_*  b_*

		
		/*Instructions from Venkatanarayana Motkuri Centre for Economic and Social Studies) were used


Consider a population of persons (or households ...), i = 1,...,n, 
with income y_i, and weight w_i. Let f_i = w_i/N, where 
    i=n
N = SUM(w_i). When the data are unweighted, w_i = 1 and N = n. 
    i=1
The poverty line is z, and the poverty gap for person i is max(0, z-y_i). 
Suppose there is an exhaustive partition of the population into 
mutually-exclusive subgroups k = 1,...,K.

The FGT class of poverty indices is given by
                  
                   i=n             
        FGT(a) =   SUM (f_i).(I_i).[(z-y_i)/z)]^a
                   i=1             

where I_i = 1 if y_i < z and I_i = 0 otherwise.
*/

	gen 	poor=1 	if 				exp<165879
	recode 	poor 	(.=0)
	sum 	poor
	local 	z= 		r(mean)*r(N)

	foreach i in 1 2 {
			gen 	FGT`i'= 	((1/2100)*(((165869-exp)/165869))^`i') if poor==1
			recode 	FGT`i'  	(.=0)
			replace FGT`i'=		FGT`i' *1000
	} 

	rename poor FGT0
		
		
		keep if maize==1
		
		
		g shock=.
		
		foreach i in drought floods {
			replace shock=1  if `i'==1
		} 
	
	save  "${workingfiles}/CSA_poverty_foodsecurity_DataUnfinished.dta", replace
	
		do "${do}/IHSVclimate_do.do" 
		do "${do}/Labels.do" 
		
		
	save  "${workingfiles}/CSA_poverty_foodsecurity_Data.dta", replace		

ok

	o

	biprobit (CSA   i.type  i.quality drought  Plot_Area ) (FGT0 age gender i.marital drought reside fisp TLU ), technique(bhhh)
	
	
 
	
	*Outliers
	
		foreach v of varlist  HDDS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<1.3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>1.3 & CSA!=1
}

		drop z_* a_* m_*
	
		foreach v of varlist  FCS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
		replace `v'=m_`v' if z_`v'>3 & CSA!=1
}

		drop z_* a_* m_*
	
		foreach v of varlist  FCS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'<-1.9 & CSA==1
		replace `v'=m_`v' if z_`v'>3 & CSA!=1
}

		drop z_* a_* m_*
		
				
		foreach v of varlist  productivity {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'<-0.19 
			replace `v'=m_`v' if z_`v'>3 
}

		drop z_* a_* m_*
		
		
		foreach v of varlist  productivity {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>3 & combined!=1 
}

		drop z_* a_* m_*
		
		foreach v of varlist  productivity {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>3 & combined==0
}

		drop z_* a_* m_*
		foreach var of varlist productivity avr_long_tmp2019 avr_long_pre2019 avr_yearly_tmp2019 avr_yearly_pre2019 HDDS FCS  {
		g l_`var'=ln(`var')
	}
	

	*This to be restructured
	
	/*foreach dependent in productivity FCS HDDS  {
		foreach class in  0 1 2 3 {
			g		`dependent'`class'=`dependent' 		if `class'==combined
			replace `dependent'`class'=. 				if `class'!=combined
			g		l_`dependent'`class'=l_`dependent' 	if `class'==combined
			replace l_`dependent'`class'=. 				if `class'!=combined
		}
	}
	*/	
		
		
	save "${workingfiles}/`IHSnumber'Proposal_Data.dta",replace
	
	}
	
/*
use "${workingfiles}/IHSVProposal_Data.dta", clear


	*Svy Set 
	svyset 	case_id 	[pweight= hh_wgt ], 	strata( ea_id ) 	singleunit(centered)

	
**# OBJECTIVE 1  : farmers' adoption/participation of the coupling of FISP with SAPs.

	collect 	clear
	
	cd "C:/Users/user/Documents/Manu Scripts/Wisdom Proposal/Models"
	
	foreach 	dependent	in	fisp_saps 	input_subsidy 	saps {
		probit `dependent' $socio $insitutional $farmlevel  $weather
		collect _r_b _r_se , tag(model[(`dependent')]): margins,  dydx(*) post
	}

		collect dims
		collect levelsof 	model
		collect label 		list 	model, 	all
		collect label 		list 	result, all

		collect levelsof 	result
		collect label 		list 	result, all

		collect stars 		_r_p 0.01 "***" 0.05 "**" 0.1 "*" 1  " ", attach(_r_b) 
		collect layout 		(colname#result) 	(model)
                                 
						*Removing base levels for factor variables on the output table                   
		collect style      showbase  off

						*Removing vertor line
		collect style 	   cell 	border_block, 	border(right, pattern(nil))  
	
						*Format
		collect style 		cell result[_r_se], sformat("(%s)") 
		collect levelsof 	cell_type
		collect style		cell 	cell_type[item column-header], halign(center)
		collect style 		header 	result, level(hide)
		collect style 		row 	stack, spacer delimiter(" x ")
		collect style 		cell, 	nformat(%10.4f)
		collect style 		putdocx, layout(autofitcontents)
		collect export 		Probit Moodels.docx, as(docx) replace
		
	
	
	*Robust 
		
		est clear
		rbiprobit input_subsidy = $socio $insitutional $farmlevel  $weather, endog( saps = $socio $insitutional $farmlevel  $weather)
		est sto FISP 
	
		rbiprobit saps = $socio $insitutional $farmlevel  $weather, endog( input_subsidy = $socio $insitutional $farmlevel  $weather)
		est sto SAPs
		
		esttab FISP SAPs using Fvalues.rtf,   stats(chi2 p , labels("Wald chi" "Prob > chi2" ))  star(* 0.10 ** 0.05 *** 0.01) unstack r
		
		
	
**# OBJECTIVE 2 : 
 
	*ARE YOU RUNNING THIS SCRIPT FOR THE FIRST TIME (After reopening Stata?)  Yes/No : Input the answer in the local below
	
	local runningscript_firsttime "Yes"
	
	if  "`runningscript_firsttime'"=="Yes" {
		
		do "${Do}/selmlogdo.do" 	
		
	}

		svyset 	case_id 	[pweight= hh_wgt ], 	strata( ea_id ) 	singleunit(centered)
		
		collect clear
		
	*Productivity Model
		
		foreach 	number in 0 3 2 1   { //a loop for efficiency
			
			local IV_0			extension drought IV_fisp_saps
			local IV_1			extension drought IV_fisp_saps
			local IV_2			extension drought IV_input_subsidy
			local IV_3			extension drought IV_saps
			
		*Selmlog estimation	
		
			collect _r_b _r_se, tag(model[(`number')]): selmlog productivity`number' $eq, select(combined = `IV_`number'') boot(100) dmf(0) gen(m`number')	
	
			
			// Overall significance and Number of observetions 
			test 		$eq
			local		chi2				`r(chi2)'
			collect 	chi2 = r(value),	tag(model[(`number')]):  echo	`chi2'
			
			test 		$eq
			local		p				 	`r(p)'
			collect 	p= r(value),		tag(model[(`number')]):  echo	`p'
			
			count 		if 					combined==`number'
			local 		N			 		`r(N)'
			collect 	N= r(value),		tag(model[(`number')]):  echo	`N'
		
			//predicitons for average estimations
			if `number'==0 {
					rename 		m`number'1 		_m1
					rename 		m`number'2 		_m2
					rename 		m`number'3 		_m3
					predict		y_bar_p_`number', xb
					
					ge Emz_p_`number'= 	( y_bar_p_`number' )
					ge Emz_p_`number'_1= 	Emz_p_`number' 	if 	combined  ==1
					ge Emz_p_`number'_3= 	Emz_p_`number' 	if 	combined  ==3
					ge Emz_p_`number'_2= 	Emz_p_`number'	if 	combined  ==2
					ge Emz_p_`number'_0=	Emz_p_`number'  if 	combined  ==0
			}

			if `number'==1 {
					rename 		m`number'0 		_m0
					rename 		m`number'2 		_m2
					rename 		m`number'3 		_m3
					predict		y_bar_p_`number', xb
					ge Emz_p_`number'= 	( y_bar_p_`number' )
					ge Emz_p_`number'_1= 	Emz_p_`number' 	if 	combined  ==1
					ge Emz_p_`number'_3= 	Emz_p_`number' 	if 	combined  ==3
					ge Emz_p_`number'_2= 	Emz_p_`number'	if 	combined  ==2
					ge Emz_p_`number'_0=	Emz_p_`number'  if 	combined  ==0
			}
			
			if `number'==2 {
					rename 		m`number'0  	_m0
					rename 		m`number'1 		_m1
					rename 		m`number'3		_m3
					predict		y_bar_p_`number', xb
					ge Emz_p_`number'= 	( y_bar_p_`number' )
					ge Emz_p_`number'_1= 	Emz_p_`number' 	if 	combined  ==1
					ge Emz_p_`number'_3= 	Emz_p_`number' 	if 	combined  ==3
					ge Emz_p_`number'_2= 	Emz_p_`number'	if 	combined  ==2
					ge Emz_p_`number'_0=	Emz_p_`number'  if 	combined  ==0
			}
			
			if `number'==3 {
					rename 		m`number'0  	_m0
					rename 		m`number'1 		_m1
					rename 		m`number'2 		_m2
					predict		y_bar_p_`number', xb
					ge Emz_p_`number'= 	( y_bar_p_`number' )
					ge Emz_p_`number'_1= 	Emz_p_`number' 	if 	combined  ==1
					ge Emz_p_`number'_3= 	Emz_p_`number' 	if 	combined  ==3
					ge Emz_p_`number'_2= 	Emz_p_`number'	if 	combined  ==2
					ge Emz_p_`number'_0=	Emz_p_`number'  if 	combined  ==0
			}
			
		}
		
	
		collect dims
		collect levelsof model
		collect label list model, all
		collect label list result, all

		collect levelsof result
		collect label list result, all

		collect style showbase off
		collect stars _r_p  0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(_r_b) 
		collect layout (colname#result) (model)
                                 
						*Removing base levels for factor variables on the output table                   
		collect style showbase off

						*Removing vertor line
		collect style cell border_block, border(right, pattern(nil))  

						*Format
		collect style cell result[_r_se], sformat("(%s)") 
		collect levelsof cell_type
		collect style cell cell_type[item column-header], halign(center)
		collect style header result, level(hide)
		collect style row stack, spacer delimiter(" x ")
		collect stars _r_p  0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(_r_b) 
		collect layout (colname#result result[chi2 p N]) (model)
		collect style cell result[_r_se], nformat(%8.2fc) 
		collect style cell result[chi2 p N], nformat(%8.2f)
		collect style cell, nformat(%10.2f)
		collect style header result[chi2 p N], level(label)
		collect style putdocx, layout(autofitcontents)
		collect export productivity.docx, as(docx) replace


		
		
		collect clear
*FCS Models
		foreach 	number in 0 3 2 1   { //a loop for efficiency
			
				
			local IV_0			extension drought IV_fisp_saps
			local IV_1			extension drought IV_fisp_saps
			local IV_2			extension drought IV_input_subsidy
			local IV_3			extension drought IV_saps
			
		*Selmlog estimation	
		*The if are applying due to changes in the IV
		
				 collect _r_b _r_se, tag(model[(`number')]): selmlog FCS`number' $eq, select(combined = `IV_`number'') boot(100) dmf(0) gen(m`number')	
	
			
			// Overall significance and Number of observetions 
				// Overall significance and Number of observetions 
			test 		$eq
			local		chi2				`r(chi2)'
			collect 	chi2 = r(value),	tag(model[(`number')]):  echo	`chi2'
			
			test 		$eq
			local		p				 	`r(p)'
			collect 	p= r(value),		tag(model[(`number')]):  echo	`p'
			
			count 		if 					combined==`number'
			local 		N			 		`r(N)'
			collect 	N= r(value),		tag(model[(`number')]):  echo	`N'
		
			//predicitons for average estimations
			if `number'==0 {
					rename 		m`number'1 		_m1
					rename 		m`number'2 		_m2
					rename 		m`number'3 		_m3
					predict		y_bar_f_`number', xb
					
					ge Emz_f_`number'= 	( y_bar_f_`number' )
					ge Emz_f_`number'_1= 	Emz_f_`number' 	if 	combined  ==1
					ge Emz_f_`number'_3= 	Emz_f_`number' 	if 	combined  ==3
					ge Emz_f_`number'_2= 	Emz_f_`number'	if 	combined  ==2
					ge Emz_f_`number'_0=	Emz_f_`number'  if 	combined  ==0
			}

			if `number'==1 {
					rename 		m`number'0 		_m0
					rename 		m`number'2 		_m2
					rename 		m`number'3 		_m3
					predict		y_bar_f_`number', xb
					ge Emz_f_`number'= 	( y_bar_f_`number' )
					ge Emz_f_`number'_1= 	Emz_f_`number' 	if 	combined  ==1
					ge Emz_f_`number'_3= 	Emz_f_`number' 	if 	combined  ==3
					ge Emz_f_`number'_2= 	Emz_f_`number'	if 	combined  ==2
					ge Emz_f_`number'_0=	Emz_f_`number'  if 	combined  ==0
			}
			
			if `number'==2 {
					rename 		m`number'0  	_m0
					rename 		m`number'1 		_m1
					rename 		m`number'3		_m3
					predict		y_bar_f_`number', xb
					ge Emz_f_`number'= 	( y_bar_f_`number' )
					ge Emz_f_`number'_1= 	Emz_f_`number' 	if 	combined  ==1
					ge Emz_f_`number'_3= 	Emz_f_`number' 	if 	combined  ==3
					ge Emz_f_`number'_2= 	Emz_f_`number'	if 	combined  ==2
					ge Emz_f_`number'_0=	Emz_f_`number'  if 	combined  ==0
			}
			
			if `number'==3 {
					rename 		m`number'0  	_m0
					rename 		m`number'1 		_m1
					rename 		m`number'2 		_m2
					predict		y_bar_f_`number', xb
					ge Emz_f_`number'= 	( y_bar_f_`number' )
					ge Emz_f_`number'_1= 	Emz_f_`number' 	if 	combined  ==1
					ge Emz_f_`number'_3= 	Emz_f_`number' 	if 	combined  ==3
					ge Emz_f_`number'_2= 	Emz_f_`number'	if 	combined  ==2
					ge Emz_f_`number'_0=	Emz_f_`number'  if 	combined  ==0
			}
			
		}
		
	
		collect dims
		collect levelsof model
		collect label list model, all
		collect label list result, all

		collect levelsof result
		collect label list result, all

		collect style showbase off
		collect stars _r_p  0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(_r_b) 
		collect layout (colname#result) (model)
                                 
						*Removing base levels for factor variables on the output table                   
		collect style showbase off

						*Removing vertor line
		collect style cell border_block, border(right, pattern(nil))  

						*Format
		collect style cell result[_r_se], sformat("(%s)") 
		collect levelsof cell_type
		collect style cell cell_type[item column-header], halign(center)
		collect style header result, level(hide)
		collect style row stack, spacer delimiter(" x ")
		collect stars _r_p  0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(_r_b) 
		collect layout (colname#result result[chi2 p N]) (model)
		collect style cell result[_r_se], nformat(%8.2fc) 
		collect style cell result[chi2 p N], nformat(%8.2f)
		collect style cell, nformat(%10.2f)
		collect style header result[chi2 p N], level(label)
		collect style putdocx, layout(autofitcontents)
		collect export FCS.docx, as(docx) replace




		collect clear
*HDDS Models
		foreach 	number in 0 3 2 1   { //a loop for efficiency
			
				
			local IV_0			extension drought IV_fisp_saps
			local IV_1			extension drought IV_fisp_saps
			local IV_2			extension drought IV_input_subsidy
			local IV_3			extension drought IV_saps
			
		*Selmlog estimation	
		*The if are applying due to changes in the IV
		
				 collect _r_b _r_se, tag(model[(`number')]): selmlog HDDS`number' $eq, select(combined = `IV_`number'') boot(100) dmf(0) gen(m`number')	
	
			
			// Overall significance and Number of observetions 
	// Overall significance and Number of observetions 
			test 		$eq
			local		chi2				`r(chi2)'
			collect 	chi2 = r(value),	tag(model[(`number')]):  echo	`chi2'
			
			test 		$eq
			local		p				 	`r(p)'
			collect 	p= r(value),		tag(model[(`number')]):  echo	`p'
			
			count 		if 					combined==`number'
			local 		N			 		`r(N)'
			collect 	N= r(value),		tag(model[(`number')]):  echo	`N'
		
			//predicitons for average estimations
			if `number'==0 {
					rename 		m`number'1 		_m1
					rename 		m`number'2 		_m2
					rename 		m`number'3 		_m3
					predict		y_bar_h_`number', xb
					
					ge Emz_h_`number'= 	( y_bar_h_`number' )
					ge Emz_h_`number'_1= 	Emz_h_`number' 	if 	combined  ==1
					ge Emz_h_`number'_3= 	Emz_h_`number' 	if 	combined  ==3
					ge Emz_h_`number'_2= 	Emz_h_`number'	if 	combined  ==2
					ge Emz_h_`number'_0=	Emz_h_`number'  if 	combined  ==0
			}

			if `number'==1 {
					rename 		m`number'0 		_m0
					rename 		m`number'2 		_m2
					rename 		m`number'3 		_m3
					predict		y_bar_h_`number', xb
					ge Emz_h_`number'= 	( y_bar_h_`number' )
					ge Emz_h_`number'_1= 	Emz_h_`number' 	if 	combined  ==1
					ge Emz_h_`number'_3= 	Emz_h_`number' 	if 	combined  ==3
					ge Emz_h_`number'_2= 	Emz_h_`number'	if 	combined  ==2
					ge Emz_h_`number'_0=	Emz_h_`number'  if 	combined  ==0
			}
			
			if `number'==2 {
					rename 		m`number'0  	_m0
					rename 		m`number'1 		_m1
					rename 		m`number'3		_m3
					predict		y_bar_h_`number', xb
					ge Emz_h_`number'= 	( y_bar_h_`number' )
					ge Emz_h_`number'_1= 	Emz_h_`number' 	if 	combined  ==1
					ge Emz_h_`number'_3= 	Emz_h_`number' 	if 	combined  ==3
					ge Emz_h_`number'_2= 	Emz_h_`number'	if 	combined  ==2
					ge Emz_h_`number'_0=	Emz_h_`number'  if 	combined  ==0
			}
			
			if `number'==3 {
					rename 		m`number'0  	_m0
					rename 		m`number'1 		_m1
					rename 		m`number'2 		_m2
					predict		y_bar_h_`number', xb
					ge Emz_h_`number'= 	( y_bar_h_`number' )
					ge Emz_h_`number'_1= 	Emz_h_`number' 	if 	combined  ==1
					ge Emz_h_`number'_3= 	Emz_h_`number' 	if 	combined  ==3
					ge Emz_h_`number'_2= 	Emz_h_`number'	if 	combined  ==2
					ge Emz_h_`number'_0=	Emz_h_`number'  if 	combined  ==0
			}
			
		}
		
	
		collect dims
		collect levelsof model
		collect label list model, all
		collect label list result, all

		collect levelsof result
		collect label list result, all

		collect style showbase off
		collect stars _r_p  0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(_r_b) 
		collect layout (colname#result) (model)
                                 
						*Removing base levels for factor variables on the output table                   
		collect style showbase off

						*Removing vertor line
		collect style cell border_block, border(right, pattern(nil))  

						*Format
		collect style cell result[_r_se], sformat("(%s)") 
		collect levelsof cell_type
		collect style cell cell_type[item column-header], halign(center)
		collect style header result, level(hide)
		collect style row stack, spacer delimiter(" x ")
		collect stars _r_p  0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(_r_b) 
		collect layout (colname#result result[chi2 p N]) (model)
		collect style cell result[_r_se], nformat(%8.2fc) 
		collect style cell result[chi2 p N], nformat(%8.2f)
		collect style cell, nformat(%10.2f)
		collect style header result[chi2 p N], level(label)
		collect style putdocx, layout(autofitcontents)
		collect export HDDS.docx, as(docx) replace

		*Unconditional Average treatment effects  (ATU)
		local command  "command( Use= r(mu_1)  Non_Use= r(mu_2) (Difference =r(mu_1)-r(mu_2)) pvalue = r(p)"
		
		table (command) (result),   `command'   : ttest Emz_p_1==Emz_p_0 ) `command'   : ttest Emz_p_2==Emz_p_0 ) `command'   : ttest Emz_p_3==Emz_p_0 ) ///
		`command'   : ttest Emz_f_1==Emz_f_0 ) `command'   : ttest Emz_f_2==Emz_f_0 ) `command'   : ttest Emz_f_3==Emz_f_0 ) ///
		`command'   : ttest Emz_h_1==Emz_h_0 ) `command'   : ttest Emz_h_2==Emz_h_0 ) `command'   : ttest Emz_h_3==Emz_h_0 )
		
		
		collect style cell result[ Use Non_Use Difference ], nformat(%10.2f)
		collect stars pvalue 0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(Difference) 
		collect style putdocx, layout(autofitcontents)
		collect export ATU_Unconditional.docx, as(docx) replace
		
		*Average treatment effects on the Treated  (ATT)
		local command  "command( Use= r(mu_1)  Non_Use= r(mu_2) (Difference =r(mu_1)-r(mu_2)) pvalue = r(p)"
		
		table (command) (result),   `command'   : ttest Emz_p_1_1==Emz_p_0_1 ) `command'  : ttest Emz_p_2_2==Emz_p_0_2 ) `command'   : ttest Emz_p_3_3==Emz_p_0_3 ) ///
		`command'   : ttest Emz_f_1_1==Emz_f_0_1 ) `command'   : ttest Emz_f_2_2==Emz_f_0_2 ) `command'   : ttest Emz_f_3_3==Emz_f_0_3 ) ///
		`command'   : ttest Emz_h_1_1==Emz_h_0_1 ) `command'   : ttest Emz_h_2_2==Emz_h_0_2 ) `command'   : ttest Emz_h_3_3==Emz_h_0_3 )
		
		collect style cell result[ Non_Use Use Difference ], nformat(%10.2f)
		collect stars pvalue 0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(Difference) 
		collect style putdocx, layout(autofitcontents)
		collect export ATT_Conditional.docx, as(docx) replace
		
		*Heterogeniety effects
		local command  "command( Combination= r(mu_1)  Combination2= r(mu_2) (Difference =r(mu_1)-r(mu_2)) pvalue = r(p)"
		
		table (command) (result),   `command'   : ttest Emz_p_3_1==Emz_p_2_1 ) `command'  : ttest Emz_p_3_2== Emz_p_1_2 ) `command'   : ttest Emz_p_2_3== Emz_p_1_3 ) ///
		`command'   : ttest Emz_f_3_1==Emz_f_2_1 ) `command'  : ttest Emz_f_3_2== Emz_f_1_2 ) `command'   : ttest Emz_f_2_3== Emz_f_1_3 ) ///
		`command'   : ttest Emz_h_3_1==Emz_h_2_1 ) `command'  : ttest Emz_h_3_2== Emz_h_1_2 ) `command'   : ttest Emz_h_2_3== Emz_h_1_3 ) 

		collect style cell result[ Combination Combination2 Difference ], nformat(%10.2f)
		collect stars pvalue 0.01 "***" 0.05 "** " 0.1 "* " 1 " ", attach(Difference) 
		collect style putdocx, layout(autofitcontents)
		collect export Heterogenietyeffects.docx, as(docx) replace
		
		
		*/
		
		
		* Best 
biprobit ( CSA = extension credit drought floods age gender hh_size  FGT0  )  (FGT0 = fisp com_cd70 reside dependency off_farm age  )

*Best
biprobit ( CSA = extension credit drought floods age gender hh_size  FGT0 fisp  )  (FGT0 =  com_cd70 reside dependency off_farm  gender age hh_size  marital2 marital3  )



*Second best 

biprobit ( CSA = extension credit drought floods age gender hh_size  FGT0 fisp Plot_Area  )  (FGT0 =  com_cd70 reside dependency off_farm  gender age hh_size  marital2 marital3  extension credit  floods)

biprobit ( CSA = extension credit drought floods age gender hh_size  mpi fisp lPlot_Area  )  (mpi =  com_cd70 reside dependency off_farm  gender age hh_size  marital2 marital3  extension credit  floods)



*MPI best 
biprobit ( CSA = extension credit drought floods age gender hh_size  mpi fisp Plot_Area type2 type3 type4  quality2 quality3 )  (mpi =  social_nets com_cd70 reside dependency off_farm  gender age hh_size  marital2 marital3  extension credit  floods)

biprobit ( CSA = extension credit drought floods age gender hh_size  mpi fisp  type2 type3 type4  quality2 quality3 )  (mpi = age hh_size  off_farm drought  marital2 com_cd71 social_nets )


*FGT0
biprobit ( CSA = extension credit drought floods age gender hh_size  FGT0 fisp Plot_Area type2 type3 type4  quality2 quality3 )  (FGT0 = com_cd70 reside dependency off_farm  gender age hh_size  marital2 marital3  extension credit  floods)

biprobit ( CSA = extension credit drought floods age gender hh_size  FGT0 fisp Plot_Area type2 type3 type4  quality2 quality3 )  (FGT0 =  social_nets com_cd70 reside dependency off_farm  gender age hh_size  marital2 marital3  extension credit  floods)

biprobit ( CSA = extension credit drought floods age gender hh_size  FGT0 fisp Plot_Area  )  (FGT0 = com_cd70 reside dependency off_farm  gender age hh_size  marital2 marital3  extension credit  floods)


biprobit ( CSA = extension credit drought floods age gender hh_size  FGT0 fisp  )  (FGT0 =  com_cd70 reside dependency off_farm  gender age hh_size  marital2 marital3  )