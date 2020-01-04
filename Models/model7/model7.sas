ods pdf file = "K:\BIOS 653\project\Output_model7.pdf";
/*this version has these variables in the model:  Sex Group*days Fatmass_cent MuscleGlycogen*/;
data exercise;
infile 'K:\BIOS 653\project\data_biostat653_project.csv' 
	delimiter = ','
	dsd 
	missover 
	firstobs = 2 
	DSD;
input ID $ Sex $ Group $ Days Fatmass FFM MuscleGlycogen 
COXIV GIRperkgFFMperinsulin TotalAdiponectin LogTotalAdiponectin;
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
Adiponectin_cent = TotalAdiponectin-4010.396;
MuscleGlycogen_cent = MuscleGlycogen-595.4059;
run;

proc print data = exercise_d (obs=10);
run;

title 'Unstructured';
proc mixed data = exercise_d method=reml;
class ID Group Sex;
model GIRperkgFFMperinsulin =  Sex Days Group*Days Fatmass_cent MuscleGlycogen_cent/noint covb solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated/type = un  subject = ID r rcorr;
run;

title 'rand unstrucutred, main ARH(1)';
*doesn't converge for this model;
proc mixed data = exercise_d method=reml;
class ID Group Sex;
model GIRperkgFFMperinsulin =  Sex Days Group*Days Fatmass_cent MuscleGlycogen_cent/noint covb solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated/type = ARH(1)  subject = ID r rcorr;
run;

title 'rand unstrucutred, main ARH(1), Group specific var-cov matrix ';
*doesn't converge for this model;
proc mixed data = exercise_d method=reml;
class ID Group Sex;
model GIRperkgFFMperinsulin =  Sex Days Group*Days Fatmass_cent MuscleGlycogen_cent/noint covb solution;
random intercept/type = un group = Group subject = ID g gcorr v vcorr;
repeated/type = ARH(1)  subject = ID r rcorr;
run;

title 'rand unstrucutred, main ANTE(1)';
proc mixed data = exercise_d method=reml;
class ID Group Sex;
model GIRperkgFFMperinsulin =  Sex Days Group*Days Fatmass_cent MuscleGlycogen_cent/noint covb solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated/type = ANTE(1)  subject = ID r rcorr;
run;

title 'rand unstrucutred, main csh';
proc mixed data = exercise_d method=reml;
class ID Group Sex;
model GIRperkgFFMperinsulin =  Sex Days Group*Days Fatmass_cent MuscleGlycogen_cent/noint covb solution;
random intercept/type = un subject = ID g gcorr v vcorr;
repeated/type = csh  subject = ID r rcorr;
run;


title 'rand unstrucutred, main csh, Group specific var cov matrix';
proc mixed data = exercise_d method=reml;
class ID Group Sex;
model GIRperkgFFMperinsulin =  Sex Days Group*Days Fatmass_cent MuscleGlycogen_cent/noint covb solution;
random intercept/type = un group = Group subject = ID g gcorr v vcorr;
repeated/type = csh  subject = ID r rcorr;
run;
