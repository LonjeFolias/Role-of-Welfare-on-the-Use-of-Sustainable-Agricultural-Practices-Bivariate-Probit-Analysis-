		
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