
/*
		foreach v of varlist  HDDS {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<1.3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>1.3 & CSA!=1
}

		drop z_* a_* m_*
	
		foreach v of varlist  fcs {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
		replace `v'=m_`v' if z_`v'>3 & CSA!=1
}

		drop z_* a_* m_*
	
		foreach v of varlist  fcs {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'<-1.9 & CSA==1
		replace `v'=m_`v' if z_`v'>3 & CSA!=1
}

		drop z_* a_* m_*
*/


/*
		foreach v of varlist  HDDS {
					zscore `v'
					egen a_`v'=mean(`v') if z_`v'>-1.3 & z_`v'<1.3
					egen m_`v'=mean(a_`v')
					replace `v'=m_`v' if z_`v'> 1.3 & CSA!=1
		}
			drop z_* a_* m_*
			
			
		foreach v of varlist  HDDS {
					zscore `v'
					egen a_`v'=mean(`v') if z_`v'>-1.5 & z_`v'<1.5
					egen m_`v'=mean(a_`v')
					replace `v'=m_`v' if z_`v'<-2 & CSA==1
		}
			drop z_* a_* m_*
			
			
		
		foreach v of varlist  fcs {
					zscore `v'
					egen a_`v'=mean(`v') if z_`v'>-3 & z_`v'<3
					egen m_`v'=mean(a_`v')
				replace `v'=m_`v' if z_`v'>2 & CSA!=1
				replace `v'=m_`v' if z_`v'<-1.5 & CSA==1
		}
			drop z_* a_* m_*
	
		foreach v of varlist  fcs {
					zscore `v'
					egen a_`v'=mean(`v') if z_`v'>-3 & z_`v'<3
					egen m_`v'=mean(a_`v')
				replace `v'=m_`v' if z_`v'>2 & CSA!=1
				replace `v'=m_`v' if z_`v'<-1.5 & CSA==1
		}
			drop z_* a_* m_*
			

		
			foreach v of varlist  CSI {
					zscore `v'
					egen a_`v'=mean(`v') if z_`v'>-3 & z_`v'<3
					egen m_`v'=mean(a_`v')
				replace `v'=m_`v' if z_`v'>3 & CSA!=1
		}
			drop z_* a_* m_*
			
			
		foreach v of varlist  CSI {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>3 & CSA==1
		}
		
		drop z_* a_* m_*
		
		foreach v of varlist  CSI {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>3 & CSA==1
		}
		
		drop z_* a_* m_*
		
		foreach v of varlist  CSI {
			zscore `v'
			egen a_`v'=mean(`v') if z_`v'<3
			egen m_`v'=mean(a_`v')
			replace `v'=m_`v' if z_`v'>3 & CSA==1
		}
		
		drop z_* a_* m_*
		
*/		
		
		replace		HDDS= cond(HDDS<6,1,0)

		gen FCS= cond(fcs<35,1,0)
		
		gen      rCSI= cond(CSI>18 ,1,0)
		
		********************************************************************************
	**# Macros
		********************************************************************************
		global binary dep_educ_1 dep_educ_2 dep_health_1 dep_health_2 dep_health_3 dep_health_4 dep_env1 dep_env2 dep_env3 dep_empl_1 dep_empl_2 dep_empl_3 dep_env4 organic_fertilizer inorganic_fertilizer maize  agro_forestry gender  plating_pits traditional_tilage Terraces Water_harvest_bunds organic_fertilizer agro_forestry inorganic_fertilizer maize erosion_control_bunds vetiver box_ridges minimum_tillage extension credit fisp com_cd70 com_cd71 off_farm drought floods irregularrains CSA FGT0 mpi social_nets shock
		
		********************************************************************************
	**# Renaming
		********************************************************************************		
		rename (hh_a02a  hh_s01  ag_t01  ag_e01  ag_c04c) (TAs credit extension fisp Plot_Area)
		
		
		
		********************************************************************************
	**# Recording
		********************************************************************************
		recode 	marital 	(2=1)
		recode 	marital 	(3=2)
		recode 	marital 	(4=2)
		recode 	marital 	(5=3)
		recode 	marital 	(6=2)
		
		recode  reside		(2=0)
		
		recode TLU 			(.=0)	
		

		
		********************************************************************************
	**# Defining Value labels
		********************************************************************************
		la def 	yn			1	yes			0	no
		la def	gender		1	male		0	memale
		la def 	marital 	1 	married		2 	not_married		3	widow_widower	
		la def 	type 		1 	Sandy 		2 	Between 		3	Clay			4	loam
		la def 	quality 	1 	Good 		2 	Fair 			3 	Poor
		la def 	reside 		1 	urban		0 	rural
		la def 	region 		1 	North		2 	Central			3 	Southern 
		la def	rCSI		1	Food_Insecurity	0	Food_Secure
		la def	FCS 		1	Food_Insecurity	0	Food_Secure
		la def	HDDS 		1	Food_Insecurity	0	Food_Secure
		
		
		********************************************************************************
	**# HH Attaching value labels
		********************************************************************************

		foreach var of global binary {
			recode 	`var' 	(.=0) 
			recode 	`var'	(2=0)
			la 		 val 	`var'	yn 
		}
		
		foreach variable in gender marital quality type reside region rCSI  FCS HDDS {
			la val `variable'	`variable'
		}
		
				


		********************************************************************************
	**# Variable labels 
		********************************************************************************
		la var dependency 	"HH dependancy ratio"
		la var age 			"Age of the HH head"
		la var hh_size 		"HH size"
		la var gender		"Gender of the HH head 1=male"
		la var alduts		"Number of alduts in the HH"
		la var years_village "Years spent in the area by the HH"
		la var marital		"Marital status of the HH head"
		la var dep_educ_1	"1 if all members aged 15+ have less than 8 years of schooling OR cannot read or write"
		la var dep_educ_2	"1 if at least one child aged 6–14 is not attending school"
		la var dep_health_1  "1 if the sanitation facility is not flush or a VIP latrine or a latrine with a roof OR if it is shared with other household"
		la var dep_health_2 	"1 if there is at least one child under 5 who is either underweight, stunted, or wasted"
		la var dep_health_3	"1 if their main source of water is unimproved OR it takes 30 minutes or more (round trip) to collect it"
		la var dep_env4	"1 if they do not own more than two of the following basic livelihood items: radio, television, telephone, computer, animal cart, bicycle, motorbike, or refrigerator AND do not own a car or truck"
		la var dep_env1		"1 if they do not have access to electricity"
		la var dep_env2		"1 if rubbish is disposed of on a public heap, is burnt, disposed of by other means, or there is no disposal"
		la var dep_env3		"1 if at least two of the following dwelling structural components are of poor quality: •Walls (grass, mud, compacted earth, unfired mud bricks, wood, iron sheets, or other materials) •Roof (grass, plastic sheeting, or other materials) •Floor (sand, smoothed mud, wood, or other materials)"
		la var dep_empl_1	"1 if at least one member aged 18–64 has not been working but has been looking for a job during the past 4 weeks"
		la var dep_empl_2	"1 if all working members are only engaged in farm activities, household livestock activities, or casual part-time work (ganyu)"
		la var dep_empl_3	"1 if A household is deprived if any child aged 5–17 is engaged in any economic activities in or outside of the household"
		la var com_cd70		"Is a resident of this community currently the Member of Parliament for the constituency of which this community is a part?"
		la var com_cd71		"Did the MP for this area visit the community in the past three months to speak and listen to the people?"
		la var ea_id 		"ENUMERATION AREA"
		la var Plot_Area	"Land in Acres"
		la var TLU			"Tropical Livestock Unit"
		la var maize 		"If the household produces maize"
		la var type			"Percieved soil type : 1=Sandy 2=Between 3=Clay"
		la var quality		"Percieved soil quality:  1=Good 2=Fair 3=Poor"
		la var fisp			"If the household is an input subsidy beneficiery"
		la var extension	"1 if the HH had access to extension"
		la var credit		"1 if the HH had access to credit"
		la var exp			"HH average monthly expenditure"
		la var off_farm		"If the HH was involved in Off farm activities"
		la var FCS			"Food Consumption Score : 1= Food Insecurity"
		la var fcsa			"Ordered Food Consumption Score"	
		la var HDDS			"Household Dierty Diversity Score: 1= Food Insecurity"
		la var ea_id		"Enumaration ID"
		la var reside 		"location : 1=urban	0=rural "
		la var region 		"Region : 1=North 2=Central 3=Southern"
		la var district		"DistricT"
		la var hh_wgt		"HH sample weight"
		la var CSA			"If the household used CSA strategy"
		la var FGT0			"FGT index : 1=poor 0=Otherwise"
		la var rCSI 		"Reduced Consumption Strategies Index: 1= Food Insecurity"
		la var CSI			"Reduced Consumption Strategies Index: Continous  (0-56)"
		la var dep_health_4	"1 if, in the past 12 months, they were hungry but did not eat AND went without eating for a whole day because there was not enough money or other resources for food"
		la var avr_yearly_tmp2019  "yearly average temp"
		la var avr_yearly_pre2019  "yearly average prec"
		la var mpi			"1 if multidimansoionary poor"
		la var social_nets 	"1 if the HH benefited from any social safety net"
		la var shock		"1 if the HH exprienced shock in the previous 5 years"
		la var educ			"Education level of the HH head"
		
		
		foreach word in erosion_control_bunds vetiver box_ridges minimum_tillage plating_pits traditional_tilage Terraces Water_harvest_bunds organic_fertilizer agro_forestry inorganic_fertilizer {
			la 	var	`word' 	"1 if the household used the following  CSA strategy : `word'"
		}
		
		foreach shock in drought floods irregularrains {
			la var `shock'	"1 if the household exprienced `shock' in the past 3 farming season"
		}
			
********************************************************************************
	**# Creating binaries for categorical vars
		********************************************************************************		
	foreach i in marital type quality region {
		ta `i', g(`i')
	}
	
		
		
