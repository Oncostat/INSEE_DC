/************************************************************/
/*			Mise à jour des codes communes INSEE		 	*/
/*															*/
/* 				Date de creation : 08/04/2020				*/
/* 				Author: Maryam KARIMI, SBE					*/
/************************************************************/

%MACRO code_commune(start, stop);

%if &start >= 2011 and &stop <=2018 %then %do;
	%DO I = &start %TO &stop;
	PROC IMPORT OUT= MAJ_CC.cc&I. DATAFILE= "&repertoire_commune.\majcom&I..txt" 
     DBMS=TAB REPLACE; 
	GETNAMES=YES; 
	DATAROW=2;
	GUESSINGROWS=40288; 
	RUN;

	Data MAJ_CC.cc&I.; 
	Set MAJ_CC.cc&I.; 
	Keep Dep Com Pole; 
	if pole=" " or pole="POLE" then delete; 
	Run;
	%END;
%end;

%if &start >= 2011 and &stop = 2019 %then %do;
	%DO I = &start %TO 2018;
	PROC IMPORT OUT= MAJ_CC.cc&I. DATAFILE= "&repertoire_commune.\majcom&I..txt" 
     DBMS=TAB REPLACE; 
	GETNAMES=YES; 
	DATAROW=2;
	GUESSINGROWS=40288; 
	RUN;

	Data MAJ_CC.cc&I.; 
	Set MAJ_CC.cc&I.; 
	Keep Dep Com Pole; 
	if pole=" " or pole="POLE" then delete; 
	Run;
	%END;

	* January 2019;
	PROC IMPORT OUT= MAJ_CC.cc012019   DATAFILE= "&repertoire_commune.\majcom01012019.txt" 
     DBMS=TAB REPLACE; GETNAMES=YES; DATAROW=2; GUESSINGROWS=40288; RUN;
	
	Data MAJ_CC.cc012019;
	set MAJ_CC.cc012019;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc012019; 
	Set MAJ_CC.cc012019; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

	* April 2019;
	PROC IMPORT OUT= MAJ_CC.cc042019   DATAFILE= "&repertoire_commune.\majcom01042019.txt" 
     DBMS=TAB REPLACE; GETNAMES=YES; DATAROW=2; GUESSINGROWS=40288; RUN;
	
	Data MAJ_CC.cc042019;
	set MAJ_CC.cc042019;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc042019; 
	Set MAJ_CC.cc042019; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

%end;

 
%if &start >= 2011 and &stop > 2019 and &stop <= 2021 %then %do;
	%DO I = &start %TO 2018;
	PROC IMPORT OUT= MAJ_CC.cc&I. DATAFILE= "&repertoire_commune.\majcom&I..txt" 
     DBMS=TAB REPLACE; 
	GETNAMES=YES; 
	DATAROW=2;
	GUESSINGROWS=40288; 
	RUN;

	Data MAJ_CC.cc&I.; 
	Set MAJ_CC.cc&I.; 
	Keep Dep Com Pole; 
	if pole=" " or pole="POLE" then delete; 
	Run;
	%END;

	* January 2019;
	PROC IMPORT OUT= MAJ_CC.cc012019   DATAFILE= "&repertoire_commune.\majcom01012019.txt" 
     DBMS=TAB REPLACE; GETNAMES=YES; DATAROW=2; GUESSINGROWS=40288; RUN;
	
	Data MAJ_CC.cc012019;
	set MAJ_CC.cc012019;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc012019; 
	Set MAJ_CC.cc012019; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

	* April 2019;
	PROC IMPORT OUT= MAJ_CC.cc042019   DATAFILE= "&repertoire_commune.\majcom01042019.txt" 
     DBMS=TAB REPLACE; GETNAMES=YES; DATAROW=2; GUESSINGROWS=40288; RUN;
	
	Data MAJ_CC.cc042019;
	set MAJ_CC.cc042019;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc042019; 
	Set MAJ_CC.cc042019; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

	%DO I = 2020 %TO &stop;
	PROC IMPORT OUT= MAJ_CC.cc&I. DATAFILE= "&repertoire_commune.\majcom&I..txt" 
     DBMS=TAB REPLACE; 
	GETNAMES=YES; 
	DATAROW=2;
	GUESSINGROWS=40288; 
	RUN;

	Data MAJ_CC.cc&I.;
	set MAJ_CC.cc&I.;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc&I.; 
	Set MAJ_CC.cc&I.; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

	%END;

%end;

%if &start > 2018 and &stop = 2019 %then %do;
	
	* January 2019;
	PROC IMPORT OUT= MAJ_CC.cc012019   DATAFILE= "&repertoire_commune.\majcom01012019.txt" 
     DBMS=TAB REPLACE; GETNAMES=YES; DATAROW=2; GUESSINGROWS=40288; RUN;
	
	Data MAJ_CC.cc012019;
	set MAJ_CC.cc012019;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc012019; 
	Set MAJ_CC.cc012019; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

	* April 2019;
	PROC IMPORT OUT= MAJ_CC.cc042019   DATAFILE= "&repertoire_commune.\majcom01042019.txt" 
     DBMS=TAB REPLACE; GETNAMES=YES; DATAROW=2; GUESSINGROWS=40288; RUN;
	
	Data MAJ_CC.cc042019;
	set MAJ_CC.cc042019;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc042019; 
	Set MAJ_CC.cc042019; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

%end;


%if &start = 2019 and &stop > 2019 and &stop <= 2021 %then %do;
	
	* January 2019;
	PROC IMPORT OUT= MAJ_CC.cc012019   DATAFILE= "&repertoire_commune.\majcom01012019.txt" 
     DBMS=TAB REPLACE; GETNAMES=YES; DATAROW=2; GUESSINGROWS=40288; RUN;

	Data MAJ_CC.cc012019;
	set MAJ_CC.cc012019;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc012019; 
	Set MAJ_CC.cc012019; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

	* April 2019;
	PROC IMPORT OUT= MAJ_CC.cc042019   DATAFILE= "&repertoire_commune.\majcom01042019.txt" 
     DBMS=TAB REPLACE; GETNAMES=YES; DATAROW=2; GUESSINGROWS=40288; RUN;
	
	Data MAJ_CC.cc042019;
	set MAJ_CC.cc042019;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc042019; 
	Set MAJ_CC.cc042019; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;


	%DO I = 2020 %TO &stop;
	PROC IMPORT OUT= MAJ_CC.cc&I. DATAFILE= "&repertoire_commune.\majcom&I..txt" 
     DBMS=TAB REPLACE; 
	GETNAMES=YES; 
	DATAROW=2;
	GUESSINGROWS=40288; 
	RUN;

	Data MAJ_CC.cc&I.;
	set MAJ_CC.cc&I.;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc&I.; 
	Set MAJ_CC.cc&I.; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

	%END;

%end;

%if &start > 2019 and &stop <= 2021 %then %do;

	%DO I = &start %TO &stop;
	PROC IMPORT OUT= MAJ_CC.cc&I. DATAFILE= "&repertoire_commune.\majcom&I..txt" 
     DBMS=TAB REPLACE; 
	GETNAMES=YES; 
	DATAROW=2;
	GUESSINGROWS=40288; 
	RUN;

	Data MAJ_CC.cc&I.;
	set MAJ_CC.cc&I.;
	dep_char = put(dep,2.);
	dep_char2 = put(input(dep_char,best2.),z2.);
	run;

	Data MAJ_CC.cc&I.; 
	Set MAJ_CC.cc&I.; 
	Keep Dep_char2 Com Pole;
	if pole="POLE" then delete; 
	rename dep_char2 = dep;
	Run;

	%END;

%end;

* Combining all years;
data MAJ_CC.all_cc_&stop.;
 set MAJ_CC.CC:;
run;

* Removing duplicates;
Proc sort data=MAJ_CC.all_cc_&stop. nodup; 
by Dep Com Pole; 
Run;

* Creating translation code commune dataframe;
data MAJ_CC.translation;
set MAJ_CC.all_cc_2021; 
com_char = put(com,3.);
com_char2 = put(input(com_char,best3.),z3.);
AncienCode = cats('D',input(DEP,2.),COM_char2);
NouveauCode = cats('D',put(POLE,6.));
format Anciencode 6.;
format NouveauCode 6.;
drop com_char com_char2;
run;

data MAJ_CC.translation;
set MAJ_CC.translation; 
keep AncienCode NouveauCode;
run;

%MEND code_commune;


%macro import_commune(chemin,fic_sortie);

PROC IMPORT OUT= &fic_sortie DATAFILE= "&chemin" 
	DBMS=EXCEL REPLACE;
    SHEET="Translation_Codes_Communes"; 
	GETNAMES=YES; 
	MIXED=YES; 
	SCANTEXT=YES; 
	USEDATE=YES; 
	SCANTIME=YES;
RUN;

Data &fic_sortie; 
Set &fic_sortie; 
AncienCode=ksubstr(AncienCode,2); 
NouveauCode=ksubstr(NouveauCode,2); 
Run;

%mend;
