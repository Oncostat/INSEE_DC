
%macro appariesimp(tableaa, tabledc, listevarloc, id);

%let nvarloc=1;
%do %while(%scan(&listevarloc, &nvarloc, ' ') ne ); 
	%let nvarloc=%eval(&nvarloc+1);
%end;
%let nvarloc=%eval(&nvarloc-1);

proc sort data=&tableaa;
by &listevarloc;

*Marquage des doublons;
data tableaa;
format resultat $31.;
set &tableaa;
by &listevarloc;
if first.%scan(&listevarloc, &nvarloc, ' ') and last.%scan(&listevarloc, &nvarloc, ' ') then resultat='';
																						else resultat='Doublon'; 

proc sort data=&tabledc;
by &listevarloc;

*Appariement;

data table&id reste&id;
merge tableaa (in=a ) &tabledc (in=b);
by &listevarloc;
if a and b and resultat ne 'Doublon' then do;
	resultat="&id";
	output table&id;
end;
if a and not b then output reste&id;

proc sql;
create table tabledoub
as select b.*, noigr, trim(resultat)|| " &id" as resultat
from tableaa (where=(resultat = "Doublon")) as a, &tabledc as b
where %do i2=1 %to &nvarloc-1; a.%scan(&listevarloc, &i2, ' ')=b.%scan(&listevarloc, &i2, ' ') and %end; a.%scan(&listevarloc, &nvarloc, ' ')=b.%scan(&listevarloc, &nvarloc, ' ');


*Exception Paris, Lyon et Marseille pour comdc, comdom ou comnais;

%if %index(&listevarloc, comnais) ne 0 %then %do;
	%let listevarlocarr=%sysfunc(tranwrd(&listevarloc,comnais,comnaisarr));

	data tablesarr;
	set &tabledc;
	where %if %index(&listevarloc, comnais) ne 0 %then depnais="75" or (depnais="69" and "381"<=comnais<="389") or (depnais="13" and "201"<=comnais<="216");;
	

	if depnais = "75" then comnaisarr = "056";
	if depnais = "69" and "381"<=comnais<="389" then comnaisarr = "123";
	if depnais = "13" and "201"<=comnais<="216" then comnaisarr = "055";

	drop %if %index(&listevarloc, comnais) ne 0 %then comnais;;
	

	proc sort data=tablesarr;
	by &listevarlocarr;
	
	data tablearr restearr;
	merge reste&id (in=a
	rename=(%if %index(&listevarloc, comnais) ne 0 %then comnais=comnaisarr;)
	where=(	%if %index(&listevarloc, comnais) ne 0 %then (depnais="75" and comnaisarr="056") or (depnais="69" and comnaisarr="123") or (depnais="13" and comnaisarr="055"); ))
	tablesarr (in=b) ;
	by &listevarlocarr;
	if a and b and resultat ne 'Doublon' then do;
		resultat="&id";
		output tablearr;
	end;
	if a and not b then output restearr;
	rename %if %index(&listevarloc, comnais) ne 0 %then comnaisarr=comnais;;
	
	proc sql;
	create table tabledoubarr
	as select b.*, noigr, trim(a.resultat)|| " &id" as resultat
	from reste&id (where=(resultat = "Doublon" and (
	%if %index(&listevarloc, comnais) ne 0 %then (depnais="75" and comnais="056") or (depnais="69" and comnais="123") or (depnais="13" and comnais="055"); )))
	as a, tablesarr as b
	where %do i2=1 %to &nvarloc-1; 
		%if %scan(&listevarloc, &i2, ' ')=comnais %then a.comnais=b.comnaisarr;
			%else a.%scan(&listevarloc, &i2, ' ')=b.%scan(&listevarloc, &i2, ' '); and %end;
	%if %scan(&listevarloc, &nvarloc, ' ')=comnais %then a.comnais=b.comnaisarr;
		%else a.%scan(&listevarloc, &nvarloc, ' ')=b.%scan(&listevarloc, &nvarloc, ' ');;

	data table&id;
	set table&id tabledoub (in=a) tablearr tabledoubarr (in=b);
	if a or b then resultat="&id doublon";
	run;

	data reste&id;
	set reste&id
	(where=(not(%if %index(&listevarloc, comnais) ne 0 %then (depnais="75" and comnais="056") or (depnais="69" and comnais="123") or (depnais="13" and comnais="055"); )))
	restearr;
	run;
%end;
%else %do;
	data table&id;
	set table&id tabledoub (in=a);
	if a then resultat="&id doublon";
	run;
%end;

%mend appariesimp;



%macro appariementcomp(listevar, fichier);

%let nvar=1;
%do %while(%scan(&listevar, &nvar, ' ') ne ); 
	%let nvar=%eval(&nvar+1);
%end;
%let nvar=%eval(&nvar-1);

*1.1 appariesimp avec toutes les variables, les appariés sont total;
		
	%appariesimp(&fichier, DCD_&igr_year._&lyear._converted_cl, &listevar, Total);

*1.2 sur le reste, appariesimp avec une variable en moins, les trouvés sont partiels;

	%do i=1 %to &nvar;
		%appariesimp(restetotal, DCD_&igr_year._&lyear._converted_cl, %do j=1 %to &i-1; %scan(&listevar, &j, ' ') %end; %do j=&i+1 %to &nvar; %scan(&listevar, &j, ' ') %end;, Partiel) 

		data tablepartiel&i;
		format vardif $20.;
		set tablepartiel;
		vardif="%scan(&listevar, &i, ' ')";
		
		data restepartiel&i;
		set restepartiel;
		
		proc sort data=restepartiel&i;
		by noigr;
	%end;

*1.3 merger tous les restes, les observations qui sont dans tous sont non trouvés;

	data nontrouves;
	format resultat $25.;
	merge %do i=1 %to &nvar; restepartiel&i (in=a&i) %end;;
	by noigr;
	if a1 %do i=2 %to &nvar; and a&i %end;;
	resultat='Non trouvé';

*1.4 ajouter tous les trouvés, repérer les multiples, (ou faire des scores et ne garder que le plus élevé);
	
	data total;
	set tabletotal %do i=1 %to &nvar; tablepartiel&i %end; nontrouves;

	proc sort data=total;
	by noigr;

	data total;
	set total;
	by noigr;
	if resultat ne 'Non trouvé' then do;
		if first.noigr and last.noigr then resultat=strip(resultat)|| ' unique';
		else resultat=strip(resultat)|| ' multiple';
	end;
	run;

	proc sort data=total;
	by num_insee_all;

	data total;
 	set total;
	by num_insee_all;
	if not (first.num_insee_all and last.num_insee_all) and num_insee_all not in('','0000000') then do;
		if substr(resultat,1,5) ne 'Total' then resultat=strip(resultat) ||' inter';
	end;
	run;
	

*5. Nettoyage de la work;

proc datasets;
delete table tableaa tablean tablepartiel tabletotal tablearr tablesarr tabledoub tabledoubarr nontrouves reste restepartiel restetotal restearr %do i=1 %to &nvar; restepartiel&i tablepartiel&i %end;;
quit;

%mend appariementcomp;



