*												Author : Lonjezo Erick Folias
* 												Number : 265992888003
*												Email  : lonjefolias@hotmail.com




**# Globals and Macros #

	

********************************************************************************
**# Globals, Macros, Paths, and Ados
********************************************************************************

*Ados

 	local user_commands winsor mkdir  factortest ietoolkit iefieldkit movestay asdoc  codebookout confirmdir zscore06
	  
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
    local subfolders `" "IHSV" "Working files"  "Do" "'
	

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
	
	 


	
	**# 	Food expenditure	
	use 	"${data}/HH_MOD_G1.dta", clear
			keep  		case_id 	hh_g05  		hh_g02
			reshape 	wide 		hh_g05, 		i (case_id) j (hh_g02)
			egen 		food_exp=	rowtotal(hh_g*)
			keep 		case_id 	food_exp
	save  	"${workingfiles}/exp_a.dta", replace 	
			
	**# 	Non-Food Week Expenditure		
	use 	"${data}/HH_MOD_I1.dta", clear
			keep 		case_id 	hh_i02 			hh_i03 
			reshape		wide 		hh_i03, 		i (case_id) j (hh_i02)
			egen 		week_exp=	rowtotal(hh_i*)
			replace 	week_exp=	week_exp*4*12 	// An average annual expenditure !
			keep 		case_id 	week_exp
			merge 		1:1 		case_id 		using "${workingfiles}/exp_a.dta", nogen
	save  	"${workingfiles}/exp_b.dta", replace 	
			
			
	**# 	Non-Food Month Expenditure	
	use 	"${data}/HH_MOD_I2.dta", clear
			keep 		case_id 	hh_i05 			hh_i06
			reshape 	wide 		hh_i06, 		i (case_id) j (hh_i05)
			egen 		month_exp=	rowtotal(hh_i*)
			keep 		case_id 	month_exp
			replace 	month_exp=	month_exp*12  // An average annual expenditure !
			merge 		1:1 		case_id 		using "${workingfiles}/exp_b.dta", nogen
	save  	"${workingfiles}/exp_c.dta", replace 

	**# 	Non-Food 3-Month  Expenditure	
	use "${data}/HH_MOD_J.dta", clear
			keep 		case_id 	hh_j02 		hh_j03 
			reshape 	wide 		hh_j03 , 	i (case_id) j (hh_j02)
			egen 		quater_exp=	rowtotal(hh_j*)
			replace 	quater_exp=	quater_exp*4 // An average annual expendJture !
			keep 		case_id 	quater_exp
			merge 		1:1 		case_id 	using "${workingfiles}/exp_c.dta", nogen
	save  "${workingfiles}/exp_d.dta", replace 	
			
	**#12-Month  Expenditure
	use "${data}/HH_MOD_K1.dta", clear
			keep 		case_id 	hh_k02 		hh_k03
			reshape 	wide 		hh_k03, i 	(case_id) j (hh_k02)
			egen 		annual_exp=	rowtotal(hh_k*)
			keep 		case_id 	annual_exp
			merge 		1:1 		case_id 	using "${workingfiles}/exp_d.dta", nogen
	save  "${workingfiles}/exp_f.dta", replace 	
			
			**#12-Month  Expenditure
	use "${data}/HH_MOD_K2.dta", clear
			keep 		case_id 	hh_k02 		hh_k04
			reshape 	wide 		hh_k04, i 	(case_id) j (hh_k02)
			egen 		annual2_exp=rowtotal(hh_k*)
			keep 		case_id 	annual2_exp
			merge 		1:1 		case_id 	using "${workingfiles}/exp_f.dta", nogen
	save  "${workingfiles}/exp_g.dta", replace 	
			
			
			**#durable 12-Month  Expenditure
	use "${data}/HH_MOD_L.dta", clear
			keep 		case_id 	hh_l02 		hh_l07
			reshape 	wide 		hh_l07, 	i (case_id) j (hh_l02)
			egen 		durable_exp=rowtotal(hh_l*)
			keep 		case_id 	durable_exp
			merge 		1:1 		case_id 	using "${workingfiles}/exp_g.dta", nogen
	save  "${workingfiles}/exp_h.dta", replace 	
			
			**#farm machinary 12-Month  Expenditure
	use "${data}/HH_MOD_M.dta", clear	
			egen 		exp=		rowtotal(hh_m09 hh_m06)
			keep 		case_id 	hh_m0b 		case_id  exp
			reshape 	wide exp, i (case_id) 	j (hh_m0b)
			egen 		m_exp=		rowtotal(exp*)
			keep 		case_id 	m_exp
			merge 		1:1 		case_id 	using "${workingfiles}/exp_h.dta", nogen
	save  "${workingfiles}/exp_j.dta", replace 		
			
			
			*iF NECCESSARY ADD HH enterprises please !!!!
			
			**#Education 12-Month  Expenditure
	use "${data}/hh_mod_c.dta", clear		
			keep 		hh_c22j 	case_id 	PID
			reshape 	wide 		hh_c22j, 	i(case_id) j (PID)
			egen 		edu_exp=	rowtotal(hh_c*)
			keep 		case_id 	edu_exp
			merge 		1:1 		case_id 	using "${workingfiles}/exp_j.dta", nogen
	save  "${workingfiles}/exp_k.dta", replace 		
			
			
			**#Health   Expenditure
	use "${data}/hh_mod_d.dta", clear		
			
			foreach i 		of 		varlist 	hh_d11 	hh_d12 {
					replace `i'=`i'	*12
			}
			
			egen 	health_exp		=rowtotal( hh_d11 hh_d12  hh_d12_1 hh_d14 hh_d15 hh_d16 hh_d19 hh_d10 hh_d21 hh_d48)
			keep 	health_exp 		case_id PID
			reshape wide health_exp,i(case_id) j (PID)
			egen 	health_exp=		rowtotal(health_exp*)
			keep 	case_id 		health_exp
			
			merge 1:1 case_id using "${workingfiles}/exp_k.dta", nogen
			
	save  "${workingfiles}/exp_l.dta", replace 		
						
			*egen exp=rowtotal( health_exp edu_exp m_exp durable_exp annual2_exp annual_exp quater_exp month_exp week_exp food_exp)
			*p
			*#Housing   Expenditure
			
	use "${data}/hh_mod_f.dta", clear	
		
			replace hh_f04a= 	hh_f04a
			replace hh_f04a= 	hh_f04a*365 	if 		hh_f04b==3
			replace hh_f04a= 	hh_f04a*12 		if 		hh_f04b==5
				
			replace hh_f18=		hh_f18*4*12
				
			replace hh_f25=		((360/hh_f26a)*	hh_f25) if  		hh_f26b==3
			replace hh_f25=		((48/hh_f26a)*	hh_f25) if  		hh_f26b==4
			replace hh_f25=		((12/hh_f26a)*	hh_f25) if  		hh_f26b==5

			replace hh_f32=		((360/hh_f33a)*	hh_f32) if  		hh_f33b==3
			replace hh_f32=		((48/hh_f33a)*	hh_f32) if  		hh_f33b==4
			replace hh_f32=		((12/hh_f33a)*	hh_f32) if  		hh_f33b==5
			
			replace hh_f35=		hh_f35*12 
			egen housing_exp=	rowtotal( hh_f04a hh_f04_4 hh_f04_6 hh_f18 hh_f25 hh_f32 hh_f35)
			keep case_id 		housing_exp
			
			merge 1:1 case_id using "${workingfiles}/exp_l.dta", nogen
			
			egen exp=rowtotal(housing_exp health_exp edu_exp m_exp durable_exp annual2_exp annual_exp quater_exp month_exp week_exp food_exp)
			drop *_exp
			
	save  "${workingfiles}/exp_o.dta", replace 		
	

