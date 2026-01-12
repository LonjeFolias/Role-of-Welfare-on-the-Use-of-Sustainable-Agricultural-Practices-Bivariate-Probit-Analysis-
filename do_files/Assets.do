			use "${data}/hh_mod_l.dta", clear
			
			foreach asset 		in 	507 5081 509 529 516 517 514 {
					g		assest_`asset'=1 	if		hh_l02==`asset' & hh_l01==1
			}
			
			g 	car=.
			
			foreach 	car 	in 	518 519 520	{
					replace 	car=1 			if	hh_l02==`car' & hh_l01==1
			}
			
			collapse 	(max) assest_507 assest_5081 assest_509 assest_529 assest_516 assest_517 assest_514 car  , by (case_id)
			
			save "${workingfiles}/asset1.dta", replace
			
			
			use "${data}/hh_mod_m.dta", clear
			
			foreach 	asset 	in 	609	610	613 {
					g	assest_`asset'=1 	if		hh_m0b==`asset' &  hh_m00==1
			}
			
			g 	car1=.
			
			foreach 	car 	in 	611 612	{
					replace 	car1=1 			if	hh_m0b==`car' 	&  hh_m00==1
			}

			collapse 	(max) assest_609 assest_610 assest_613 car1 , by (case_id)
						
			merge m:1 	case_id  	 	using 	"${workingfiles}/asset1.dta", 		nogen

			save "${workingfiles}/asset.dta", replace