ods pdf file = "K:\BIOS 653\project\Output_hypotheses.pdf";
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
title2 'CSH';
proc mixed data = exercise_d method=reml;
class ID Group(ref='MICT') Sex Days(ref='0');
model GIRperkgFFMperinsulin =  Sex Days  Group*Days Fatmass_cent MuscleGlycogen_cent/noint solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated Days/type = CSH  subject = ID r rcorr;
contrast 'betweendays' Days 1 -1 0, Days 0 1 -1, Days 1 0 -1/e;
contrast 'day93 vs day0' Days 0 1 -1/e;
contrast 'day93 vs day90' Days 1 -1 0/e;
contrast 'day90 vs day0' Days 1 0 -1 /e;
contrast 'Grp*Days over time1' Days 1 -1 0 Group*Days 1 -1 0, Days 0 1 -1 Group*Days 0 1 -1, Days 1 0 -1 Group*Days 1 0 -1/e;
contrast 'Grp*Days over time2'  Group*Days 1 -1 0,  Group*Days 0 1 -1,  Group*Days 1 0 -1/e;
run;

