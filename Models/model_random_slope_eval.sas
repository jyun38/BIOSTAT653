ods pdf file = "K:\BIOS 653\project\Output_need_for_random_slope.pdf";
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
run;

proc print data = exercise_d (obs=10);
run;
contrast 'between Visit 2 and Visit 3' Days 1 -1;


title 'evaluating need for random slope';
title2 'unstructured';
title3 'did not converge';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept Days/type = un subject = ID g gcorr v vcorr;
repeated Days/type = un  subject = ID r rcorr;
run;

title 'evaluating need for random slope';
title2 'AR(1)';
title3 'random slope and random intercept';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept Days/type = un subject = ID g gcorr v vcorr;
repeated Days/type = ARH(1)  subject = ID r rcorr;
run;

title 'evaluating need for random slope';
title2 'ARH(1)';
title3 'only random intercept';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = ARH(1)  subject = ID r rcorr;
run;

title 'evaluating need for random slope';
title2 'ANTE(1)';
title3 'random slope and random intercept';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept Days/type = un subject = ID g gcorr v vcorr;
repeated Days/type = ANTE(1)  subject = ID r rcorr;
run;


title 'evaluating need for random slope';
title2 'ANTE(1)';
title3 'only random intercept';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = ANTE(1)  subject = ID r rcorr;
run;



title 'evaluating need for random slope';
title2 'CSH';
title3 'random slope and random intercept';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept Days/type = un subject = ID g gcorr v vcorr;
repeated Days/type = CSH  subject = ID r rcorr;
run;


title 'evaluating need for random slope';
title2 'CSH';
title3 'only random intercept';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = CSH  subject = ID r rcorr;
run;


