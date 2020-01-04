ods pdf file = "K:\BIOS 653\project\Output_model9.pdf";
/*this version has these variables in the model:  Sex Group*days Fatmass_cent MuscleGlycogen*/;
data exercise;
infile 'K:\BIOS 653\project\data_biostat653_project.csv' 
	delimiter = ','
	dsd 
	missover 
	firstobs = 2 
	DSD;
input ID $ Sex $ Group $ Days Fatmass MuscleGlycogen GIRperkgFFMperinsulin;
run;


/*
proc contents data = exercise;
run;
*/
proc print data = exercise (obs=10);
run;


*just manaually doing the means, it's too annoying in SAS to automate it;
data exercise_d;
set exercise;
Fatmass_cent = Fatmass - 40.68;

MuscleGlycogen_cent = MuscleGlycogen-595.4059;
postVisit2 = (Days gt 90);
postVisit2_spline = postVisit2*(Days-90);
run;

proc print data = exercise_d (obs=10);
run;

/* determine fixed effects model, functional form for Days. Using ML, unstructured for both fixed and random */;
title 'Days Continuous';
proc mixed data = exercise_d method=ml;
class ID Group(ref='MICT') Sex;
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept Days/type = un subject = ID g gcorr v vcorr;
repeated/type = un  subject = ID r rcorr;
run;

title 'Days Categorical';
proc mixed data = exercise_d method=ml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept Days/type = un subject = ID g gcorr v vcorr;
repeated Days /type = un  subject = ID r rcorr;
run;


/* determine random effects model, whether random slope for time is needed. */ 
title "need for random slope, random int and slope unstructured";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept Days/type = un subject = ID g gcorr v vcorr;
repeated Days/type = un  subject = ID r rcorr;
run;
title "need for random slope, random int, unstructured";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/ noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = un  subject = ID r rcorr;
run;

/* determine random effects model, whether random slope for time is needed, cs. */ 
title "need for random slope, random int and slope unstructured";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept Days/type = un subject = ID g gcorr v vcorr;
repeated Days/type = cs  subject = ID r rcorr;
run;
title "need for random slope, random int, unstructured";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = cs  subject = ID r rcorr;
run;

/*explore different var cov matrix*/;
title "csh";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = csh  subject = ID r rcorr;
run;

title "un";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = un  subject = ID r rcorr;
run;


title "ARH(1)";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = ARH(1)  subject = ID r rcorr;
run;

title "ANTE(1)";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = ARH(1)  subject = ID r rcorr;
run;


/*need for group specific var cov matrix*/
title "need for  Group specific var cov matrix";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un group=Group subject = ID g gcorr v vcorr;
repeated Days/type = csh  subject = ID r rcorr;
run;

title "need for Sex specific var cov matrix";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un group=Sex subject = ID g gcorr v vcorr;
repeated Days/type = csh  subject = ID r rcorr;
run;

title "need for SexGroup specific var cov matrix";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un group=Sex*Group subject = ID g gcorr v vcorr;
repeated Days/type = csh  subject = ID r rcorr;
run;

title "drft final model";
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = csh  subject = ID r rcorr;
contrast "Day 90 vs 93" Days 1 -1 /e;
contrast "change with time between groups" Days 1 -1
Group*Days 1 -1 0 0 0 0
/ e ; run;
