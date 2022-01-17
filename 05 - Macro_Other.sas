%macro Remove_duplicates(table,listevar,idvar,compvarnum,compvarchar);

proc sort data = &table out = &table;
by &listevar;
run;

%let nvar=1;
%do %while(%scan(&listevar, &nvar, ' ') ne ); 
	%let nvar=%eval(&nvar+1);
%end;
%let nvar=%eval(&nvar-1);

%let lastvar = %scan(&listevar, &nvar);

data single duplicate;
set &table;
by &listevar;         
if first.&lastvar then output single; 
if not(first.&lastvar and last.&lastvar) then output duplicate;
run;

data duplicate_to_single;
set duplicate;
if substr(igr_nom_m,1,1) in ('0' '1' '2' '3' '4' '5' '6' '7' '8' '9') and 
		substr(prenom,1,1) in ('0' '1' '2' '3' '4' '5' '6' '7' '8' '9') then output;
run;

proc sort data = duplicate;
by &idvar;
run;
proc sort data = duplicate_to_single;
by &idvar;
run;

data duplicate;
merge duplicate(in = A) duplicate_to_single (in = B);
by &idvar;
if A and not B;
run;

data duplicate;
set duplicate;
array nums {*} &compvarnum;
array chars {*} compvarchar;
numMissing_char = cmiss(of chars[*]);
numMissing_num = cmiss(of nums[*]);
numMissing = numMissing_char+numMissing_num;
run;

proc sort data = duplicate;
by &listevar descending numMissing ;
run;

data duplicate_erase;
set duplicate;
by &listevar;
if last.&lastvar then delete;
keep &idvar;
run;

proc sort data = duplicate_erase;
by &idvar;
run;
proc sort data = &table;
by &idvar;
run;

* Remove duplicates from initial IGR data;
data &table._cl;
merge &table (in = A) duplicate_erase (in = B);
by &idvar;
if A and not B;
run;

%mend;
