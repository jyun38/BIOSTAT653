ods pdf file = "K:\BIOS 653\project\Output_report.pdf";
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

title 'variance covariance structure';
title2 'unstructured';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = un  subject = ID r rcorr;
run;

title 'variance covariance structure';
title2 'ARH(1)';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = ARH(1)  subject = ID r rcorr;
run;

title 'variance covariance structure';
title2 'ANTE(1)';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = ANTE(1)  subject = ID r rcorr;
run;

title 'variance covariance structure';
title2 'CSH';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = CSH  subject = ID r rcorr;
run;

title 'variance covariance structure';
title2 'CSH';
title3 'sex specific var cov structure';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = CSH  group = Sex subject = ID r rcorr;
run;

title 'variance covariance structure';
title2 'CSH';
title3 'Group specific var cov structure';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = CSH  group = Group subject = ID r rcorr;
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


title 'variance covariance structure';
title2 'CSH random intercept only';
title3 'hypothesis tests';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = CSH  subject = ID r rcorr;
contrast 'betweendays' Days 1 -1 0, Days 0 1 -1, Days 1 0 -1/e;
contrast 'day93 vs day0' Days 0 1 -1/e;
contrast 'day93 vs day90' Days 1 -1 0/e;
contrast 'day90 vs day0' Days 1 0 -1 /e;
contrast 'all group*time interact' Group*Days 1 -1 0 -1 1 0, Group*Days 1 0 -1 -1 0 1 /e;  
run;

