libname bio653 "\\mcomm-schaefer-turbo.turbo.storage.umich.edu\mcomm-schaefer-turbo\DVT\Document\2018Fall653";
/* creating a unique subject identifier */
data proydataid; set bio653.proydata;
newid = _N_;
run;
/* convert ata to format with one line per observation (multiple lines per subject; long format)*/
data proyuniv;
set proydataid;
time = 8 ; dist=Y1; output;
time = 10 ; dist=Y2; output;
time = 12 ; dist=Y3; output;
time = 14 ; dist=Y4; output;
drop Y1 Y2 Y3 Y4;
run;

/* First, an OLS fit */
title 'OLS fit';
proc glm data=proyuniv;
class gender;
model dist=gender gender*time/noint solution;
run;


title 'Model 0: intercepts random for each gender';
title2 'R_i is diagonal within-child with gender-specific variance';
title3 'D is unstructured and the same for all children';
proc mixed data=proyuniv method=ml; 
class newid gender;
model dist=gender gender*time/noint;
random intercept/ type=un subject=newid g gcorr v vcorr;
repeated/group=gender subject=newid r rcorr;
run;

title 'Model 1: intercepts and slope random for each gender';
title2 'R_i is diagonal within-child with gender-specific variance';
title3 'D is unstructured and the same for all children';
proc mixed data=proyuniv method=reml; 
class newid gender;
model dist=gender gender*time/noint;
random intercept time/ type=un subject=newid g gcorr v vcorr;
repeated/group=gender subject=newid r rcorr;
run;

title 'Model 2: intercepts and slope random for each gender';
title2 'R_i is diagonal within-child with constant variance regardless of gender - default';
title3 'D is 2 x2 unstructured and the same for all children';
proc mixed data=proyuniv method=reml; 
class newid gender;
model dist=gender gender*time/noint;
random intercept time/ type=un subject=newid g gcorr v vcorr;
estimate 'diff in mean slope' gender 0 0 gender*time 1 -1;
contrast 'overall gender difference at time 1' gender 1 -1, gender*time 1 -1/e chisq;
run;

title 'Model 3: intercepts and slope random for each gender';
title2 'R_i is AR(1) within-child with constant variance and rho regardless of gender - default';
title3 'D is 2 x2 unstructured and the same for all children';
proc mixed data=proyuniv method=reml; 
class newid gender;
model dist=gender gender*time/noint;
repeated/type=ar(1) subject=newid r rcorr;
random intercept time/ type=un subject=newid g gcorr v vcorr;
estimate 'diff in mean slope' gender 0 0 gender*time 1 -1;
contrast 'overall gender difference at time 1' gender 1 -1, gender*time 1 -1/e chisq;
run;

title 'Model 4: intercepts and slope random for each gender';
title2 'R_i is diagonal within-child, variance differ by gender, sigma_G, sigma_B';
title3 'D is 2 x2 unstructured, differ by gender';
proc mixed data=proyuniv method=reml; 
class newid gender;
model dist=gender gender*time/noint;
repeated/group=gender subject=newid r rcorr;
random intercept time/ type=un group=gender subject=newid g gcorr v vcorr;
estimate 'diff in mean slope' gender 0 0 gender*time 1 -1;
contrast 'overall gender difference at time 1' gender 1 -1, gender*time 1 -1/e chisq;
run;


title 'Model 5: intercepts and slope random for each gender';
title2 'R_i sum of 2 components: an AR(1) component for fluctuations';
title3 'and diagonal component with sigma^2, common across gender';
title4 'local option adds diagonal component to ar(1) structure'
title5 'D is 2 x2 unstructured, same for two genders';
proc mixed data=proyuniv method=reml; 
class newid gender;
model dist=gender gender*time/noint;
repeated/ type =ar(1) local subject=newid r rcorr;
random intercept time/ type=un subject=newid g gcorr v vcorr;
estimate 'diff in mean slope' gender 0 0 gender*time 1 -1;
contrast 'overall gender difference at time 1' gender 1 -1, gender*time 1 -1/e chisq;
run;

/* outpred gets BLUPs for individual estimated means */
/* ODS statement in second call produces datasets containing fixed */
/* effect estimates and the BLUPs for individual slopes and intercepts */

title 'R_i separate for each gender and diagonal';
title2 'D unstructured';
proc mixed data=proyuniv method=ml;
class newid gender;

model dist=gender gender*time/noint solution outpred=pdata;
repeated/group=gender subject=newid;
random intercept time/type=un subject=newid solution;
run;
proc print data=pdata;run;

title '2nd call: R_i separate for each gender and diagonal';
title2 'D unstructured';
proc mixed data=proyuniv method=ml;
class newid gender;
model dist=gender time*gender/noint solution;
repeated/group=gender subject=newid;
random intercept time/type=un subject=newid solution;
ods listing exclude SolutionF;
ods output SolutionF=fixedi;
ods listing exclude SolutionR;
ods output SolutionR=randi;
run;

data fixedi; set fixedi;
keep gender effect estimate;
run;

title3 'FIXED EFFECTS data';
proc print data=fixedi; run;
proc sort data=fixedi; by gender; run;


data fixedi2; set fixedi; by gender;
retain fixint fixslope;
if effect='GENDER' then fixint=estimate;
if effect='time*GENDER' then fixslope=estimate;
if last.GENDER then do;
output; fixint=.; fixslope=.;
end;
drop effect estimate;
run;

title3 'RECONFIGURED FIXED EFFECTS DATA';
proc print data=fixedi2; run;

data randi; set randi;
gender=1; if newid<12 then gender=0;
keep newid gender effect estimate;
run;

title3 'random effects output data';
proc print data=randi; run;

proc sort data=randi; by newid; run;

data randi2; set randi; by newid;
retain ranint ranslope;
if effect='Intercept' then ranint=estimate;
if effect='time' then ranslope=estimate;
if last.newid then do;
output; ranint=.;ranslope=.;
end;
drop effect estimate;
run;

proc sort data=randi2; by gender newid; run;

title3 'reconfigured RE dataset';
proc print data=randi2;run;

data fixedi2;retain gender2;set fixedi2;
if gender='F' then gender2=0; else gender2=1;
drop gender;run;

data fixedi2; retain gender; set fixedi2;
gender=gender2;drop gender2;run;

data bothi; merge fixedi2 randi2; by gender;
beta0i=fixint+ranint;
beta1i=fixslope+ranslope;
run;

title3 'random intercepts and slopes';
proc print data=bothi; run;


