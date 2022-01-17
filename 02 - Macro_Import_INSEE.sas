/********************************************************************/
/*			Import mortality data obtained from INSEE website	 	*/
/*																	*/
/* 				Date de creation : 08/04/2020						*/
/* 				Author: Maryam KARIMI, SBE							*/
/********************************************************************/


%macro import_insee(chemin,fic_sortie,code_insee);

%local chemin fic_sortie code_insee;

PROC IMPORT OUT= &fic_sortie DATAFILE= "&chemin" 
     dbms=dlm REPLACE;
	delimiter=';'; 
	GETNAMES=YES; 
	DATAROW=2;
	GUESSINGROWS=500000;
	RUN;

data &fic_sortie;
set &fic_sortie;
datedeces_char = put(datedeces,8.);
datenaiss_char = put(datenaiss,8.);
attrib datedeces_char format = 10.;
attrib datenaiss_char format = 10.;
run;

data &fic_sortie;
set &fic_sortie;
drop datedeces datenaiss;
rename datedeces_char = datedeces;
rename datenaiss_char = datenaiss;
run;


/* Create variables */
data &fic_sortie;
set &fic_sortie;
retain num_insee 0;
num_insee=num_insee+1;
nom=TRIM(scan(nomprenom,1,"*"));
prenom1=SCAN(TRIM(scan(scan(nomprenom,2,"*"),1,"/")),1);
prenom2=SCAN(TRIM(scan(scan(nomprenom,2,"*"),1,"/")),2);
prenom3=SCAN(TRIM(scan(scan(nomprenom,2,"*"),1,"/")),3);
d_nais_y=input(substr(datenaiss,1,4),8.);
d_nais_m=input(substr(datenaiss,5,2),8.);
d_nais_d=input(substr(datenaiss,7,2),8.);
d_nais=mdy(input(substr(datenaiss,5,2),8.),input(substr(datenaiss,7,2),8.),input(substr(datenaiss,1,4),8.));
d_nais2=cats(input(substr(datenaiss,5,2),$2.),input(substr(datenaiss,7,2),$2.),input(substr(datenaiss,1,4),$4.));
d_dc_y=input(substr(datedeces,1,4),8.);
d_dc_m=input(substr(datedeces,5,2),8.);
d_dc_d=input(substr(datedeces,7,2),8.);
d_dc=mdy(input(substr(datedeces,5,2),8.),input(substr(datedeces,7,2),8.),input(substr(datedeces,1,4),8.));
lieunais=commnaiss;
clieunais=lieunaiss;
paysnais=paysnaiss;
clieudc=lieudeces;
label 
num_insee="Numero INSEE automatique"
nom="Nom de naissance"
prenom1="Premier prénom"
prenom2="Deuxième prenom"
prenom3="Troisieme prenom"
sexe="Sexe"
d_dc="Date de décès"
d_dc_y="Date de décès (year)"
d_dc_m="Date de décès (month)"
d_dc_d="Date de décès (day)"
d_nais="Date de naissance"
d_nais_y="Date de naissance (year)"
d_nais_m="Date de naissance (month)"
d_nais_d="Date de naissance (day)"
d_nais2="Date de naissance (char.)"
lieunais="Lieu de naissance, en clair"
paysnais="Pays de naissance"
clieunais="Lieu de naissance, code"
clieudc="Lieu de décès, code";
format d_nais d_dc date9.;
informat d_nais d_dc date9.;
run;


data &fic_sortie;
set &fic_sortie;
if sexe=2 then sexe_maj="F";
if sexe=1 then sexe_maj="M";
run;

data &fic_sortie;
set &fic_sortie;
nom1=SCAN(TRIM(scan(nom,1,"/")),1);
nom2=SCAN(TRIM(scan(nom,1,"/")),2);
nom3=SCAN(TRIM(scan(nom,1,"/")),3);
run;

/* Combine prenom1 and prenom2 if size of prenom1 is less than 3 : example AB DEL -> ABDEL */
data &fic_sortie;
set &fic_sortie;
if length(prenom1)<=2 and length(prenom2)>1 then
	do;
	prenom1_new=trim(prenom1)||prenom2;
	prenom2_new=prenom3;
	end;
else
	do;
	prenom1_new=prenom1;
	prenom2_new=prenom2;
	prenom3_new=prenom3;
	end;
run;


data &fic_sortie;
set &fic_sortie;
drop prenom1 prenom2 prenom3;
rename prenom1_new=prenom1;
rename prenom2_new=prenom2;
rename prenom3_new=prenom3;
run;


data &fic_sortie;
set &fic_sortie;
prenom = cats(prenom1,prenom2);
prenom_comp = cats(prenom,prenom3);
nom_all = cats(nom1,nom2);
nom_comp = cats(nom_all,nom3);
drop nom_all prenom;
run;


/* Update codes of place of birth */
data &code_insee;
set &code_insee;
clieunais=put(anciencode,$5.);
run;

proc sort data=&code_insee;
by clieunais;
run;

proc sort data=&fic_sortie;
by clieunais;
run;

data &fic_sortie;
merge &fic_sortie &code_insee;
by  clieunais;
if num_insee=. then delete;
if anciencode ne . then clieunais_maj=NouveauCode  ;
if anciencode = . then clieunais_maj=clieunais  ;
run;

data &fic_sortie;
set &fic_sortie;
drop anciencode NouveauCode;
run;

data &fic_sortie;
set &fic_sortie;
if clieunais_maj ne '.' then do;
	if length(clieunais_maj)>1 and length(clieunais_maj)<5 then do;
		depnais = trim('0')||substr(clieunais_maj,1,1);
		comnais = substr(clieunais_maj,2,3);
	end;
	else do;
		if substr(clieunais_maj,1,2) in ('2A' '2B') then do;
			depnais = substr(clieunais_maj,1,2);
			comnais = substr(clieunais_maj,3,3);
		end;
		else do;
			if substr(clieunais_maj,1,2) not in ('97') then do;
				depnais = substr(clieunais_maj,1,2);
				comnais = substr(clieunais_maj,3,3);
			end;
			else do;
				depnais = substr(clieunais_maj,1,3);
				comnais = substr(clieunais_maj,4,2);
			end;
		end;
	end;
end;
else do;
	depnais = '';
	comnais = '';
end;
run;

%mend;


%MACRO import_insee_all(f_year,l_year);

%local I base_insee_csv base_insee;

	%DO I = &f_year %TO &l_year;

		%let base_insee_csv=&repertoire_INSEE\deces-&I..csv;
			
		%let base_insee	= INSEE.dcd&I; 
		
		%import_insee(&base_insee_csv,&base_insee,MAJ_CC.code_insee);

	%END;

%MEND;


%MACRO combine_insee(f_year,l_year);

data INSEE.DCD_&f_year._&l_year.;
  set
%do yr=&f_year %to &l_year;
   INSEE.DCD&yr.
%end;
  ;
run;

data INSEE.DCD_&f_year._&l_year.;
set INSEE.DCD_&f_year._&l_year.;
if d_dc_y >= &igr_year then output;
run;

data INSEE.DCD_&f_year._&l_year.;
set INSEE.DCD_&f_year._&l_year.;
retain num_insee_all 0;
num_insee_all=num_insee_all+1;
run;

%MEND;
