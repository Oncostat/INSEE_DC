# INSEE_DC : Chaîner une base de données hospitalière avec les données de mortalité INSEE

La procédure de mise à jour des données de mortalité d'une base hospitalière à partir des données de l'INSEE consiste à chercher les individus communs (sur une combinaison des variables directement identifiantes à savoir, nom, prénom, date de naissance, commune et département de naissance) entre les deux bases.

La procédure peut être mise en place en 2 étapes principales :

1. Préparation des données
2. Appariement

## 1.	Préparation des données

Avant de se lancer dans la recherche des individus communs entre les deux bases, il faut harmoniser les bases hospitalière et INSEE (Etape préparation des données). La préparation des données consiste à mettre à jour les communes de naissance de l'INSEE, importer toutes les bases de l'INSEE, et importer la base hospitalière. 

### 1.1.	Mettre à jour des communes/départements et les importer dans SAS

En France, tous les ans, les communes sont objet à différent changement lié aux changements de nom, création, fusion et suppression des communes, etc… Dans la base INSEE, les communes/départements de naissance déclarés correspondent aux codes de la commune (code officiel géographique) au moment du décès et dans la base IGR, les communes/départements de naissance déclarés correspondent aux codes de la commune au moment de la création du dossier des patients. Afin de pouvoir comparer les deux bases sur cette variable, il faut les mettre à jour sur la base de l'année en cours. Il est donc nécessaire de créer un fichier de référence contenant deux colonnes, une pour les anciens codes communes et une pour les nouveaux codes communes correspondants. A préciser que cette étape est indispensable lorsque l'INSEE publie un nouveau fichier de mise à jour des codes communes. Ces fichiers sont téléchargeables sur le site de l'INSEE : https://www.insee.fr/fr/information/2560452

Jusqu'à 2016, l'INSEE produisait les fichiers de mise à jour, donc pour les années 1999 à 2016, il suffit juste de télécharger ces fichiers qui se trouvent sous la rubrique « Mise à jour des communes » en format .txt nommé "majcomAAAA.txt" où AAAA est l'année correspondante. 

Pour les autres années, il faut créer les fichiers de mise à jour. Pour cela, en première étape il faut télécharger les fichiers des communes qui se retrouvent sous la rubrique "Liste des communes de la métropole et Dom (toutes les communes ayant existé depuis 1943)" et l'historique des communes qui se retrouvent sous la rubrique "Historique des communes". Le format de ces fichiers est en .txt de jusqu'à 2018. A partir de l'année 2019, Il faut télécharger les fichiers correspondants sous la rubrique "Événements sur les communes" au format .csv. A noter que pour l'année 2019, deux fichiers existent (1er janvier et 1er avril). 

Une fois que tous les fichiers mise à jour ont été obtenu, la macro SAS "code_commune" (définie dans le programmme "01 - Macro_Maj_INSEE.sas") doit être utilisé pour les mettre en format nécessaire, les combiner tous ensemble, supprimer les dupliqués, et créer un fichier avec 2 colonnes, les anciens codes et les nouveaux codes. Cette macro prendra en argument une année de début et une année de fin. Ensuite cette table sera exportée dans un fichier Excel "Translation_Codes_Communes.xls". La macro "import_commune" (définie dans le programme "01 - Macro_Maj_INSEE.sas" sera utilisée par la suite pour enlever le caractères ‘D’, qui se trouve avant chaque code commune.

### 1.2.	Importer les données de l'INSEE

Les fichiers des personnes décédées en France peuvent être téléchargés depuis le site de l'INSEE : https://www.insee.fr/fr/information/4190491

Ces fichiers sont en format .csv et sont nommés par deces-AAAA.csv où AAAA est l'année correspondante. Pour l'année en cours, l'INSEE publie un fichier par mois. Donc si nous sommes au milieu d'une année et qu'on a plusieurs fichiers pour l'année courante, il faut concaténer tous les fichiers de cette année et nommer le fichier total comme les autres années.

Importation des données de l'INSEE se fera en plusieurs étapes par les macros définies dans le programme "02 - Macro_Import_INSEE.sas". Ce programme contient plusieurs macros qui seront détaillées par la suite :
 
-	Macro "import_insee" : pour importer le fichier de l'INSEE d'une année, mettra certaines variables (comme la date de naissance et la date de décès) en format nécessaire, créer les variables comme les noms, les prénoms, les jours, les mois et les années de naissance et de décès, faire la mise à jour des communes de naissance en utilisant la base obtenue à l'étape précédente, séparer les départements et les communes de naissance et créer une variable contenant une suite de caractère de tous les prénoms déclarer pour une personne sans espace.

-	Macro "import_insee_all" qui utilise la macro "import_insee". Nous devons préciser une année de début et une année de fin. Cette macro ensuite importera les fichiers de l'INSEE année par année. Compte tenu la taille importante des fichiers de chaque année (en France on a plus de 500 000 décès par an), cette étape sera assez longue et il n'est pas nécessaire de la lancer à chaque fois. Si l'INSEE modifie un fichier ou ajoute un nouveau fichier, il suffit juste de lancer cette macro pour l'année en question. 

-	Macro "combine_insee" :  combiner tous les fichiers des personnes décédées en France. Pour cette étape, on peut choisir l'année du début, en fonction de l'année de la base hospitalière. A titre exemple, si l'appariement est pour les patients d'un hôpital en 2016, étant donné que la date de décès potentiel de ces patients, arrivera après 2016, nous pouvons exécuter cette macro pour 2016 à l'anneé en cours. En raison de l'arrivée tardive des certificats de décès, on peut avoir des décès apparaissant dans la base pour des années ultérieurs à l'année du décès, donc il faut choisir dans un deuxième temps les décès qui ont eu lieu courant l'année de la base hospitalière ou supérieure à cette année. Cette étape est incluse dans la macro de combinaison.

### 1.3.	Importer la base hospitalière

Cette macro est a écrire par les propriétaire de la base hospitalière. La macro doit supprimer les dupliqués en utilisant les numéros de dossier, créer les variables comme les noms, les prénoms, les jours, les mois et les années de naissance, mettre en format nécessaires les dates, faire une mise à jour des codes communes de naissance, retirer les chiffres et les symboles des noms et des prénoms (s'il existe), séparer les départements et les communes de naissance et créer une variable contenant une suite de caractère de tous les prénoms déclarés pour un patient sans espace.

## 2.	Appariement

L'algorithme d'appariement utilisé est basé sur l'un des algorithmes d'appariement déterministe que le CépiDc (Centre d’épidémiologie sur les causes médicales de décès) – INSERM (https://www.cepidc.inserm.fr/) utilise pour faire un chaînage entre la base des causes médicales de décès et les autres bases. Plus précisément, il s'inspire de l'algorithme utilisé dans la thèse (Mechinaud Lamarche - Vadel 2014) qui a inspiré la création du SNDS. Pour avoir une bonne idée de l'état de l'art sur les méthodes d'appariement, on pourra consulter l'article (Bounebache et al. 2018). La différence entre cet algorithme modifié et l'algorithme de base est sur le fait qu'on n'a pas les dates de décès, par contre on a les noms et les prénoms et donc nous avons besoin une étape supplémentaire avant l'appariement principal pour faire une transformation phonétique des noms et des prénoms (Pour éviter de perdre les matchs à cause des orthographes et les petites erreurs de saisies).

### 2.1. Phonex

Pour la transformation phonétique, notre algorithme est basé sur l'algorithme Phonex, originalement proposé par Frédéric BROUARD. Phonex est un algorithme de Soundex (https://sqlpro.developpez.com/cours/soundex/), perfectionné pour la langue française, un algorithme phonétique d'indexation de noms par leur prononciation. L'un des avantages de Phonex est qu'il sait reconnaître différents types de sons comme les sons ‘on’, ‘ai’, ‘ein’, etc…

Un programme Python de Phonex est disponible sur le github (https://github.com/lovasoa/phonex/tree/master/phonex) qui nous donne un chiffre réel pour chaque chaîne de caractère. En faisant une petite modification dans le programme original, nous avons un programme Python ("phonex.py") qui nous donne à la fois les chiffres réels et à la fois les noms et les prénoms phonétiquement modifiés.

Le programme phonex.py contient plusieurs fonctions :

-	remove_accents : pour enlever les accents

-	phonex : faire des modifications sur une chaîne de caractère au niveau phonétique

-	phonex_num : faire des modifications sur une chaîne de caractère au niveau phonétique, et transformer la chaîne de caractère modifiée en un chiffre réel

Les noms et les prénoms exportés des deux bases de données seront importés dans Python en utilisant la fonction "read_sas" du package pandas de Python. Les fonctions "phonex" et "phonex_num" seront appliquées sur les noms et les prénoms de chacune des bases hospitalière et l'INSEE. Les résultats seront enregistrés en format .csv et seront re-importer à nouveau dans SAS pour les utiliser dans la macro d'appariement. 

### 2.2 Préparation des données pour l'appariement

Après la transformation phonétique, quelques étapes seront nécessaires avant lancer le programme d'appariement :

-	Merger les noms et les prénoms convertis par Phonex avec les bases initiales.

-	Harmoniser le nom des variables entre les deux bases.

-	Supprimer les doublons potentiels dans chacune des deux bases en utilisant les noms, prénoms et les dates de naissance (et date de décès pour la base l'INSEE).
  
### 2.3 Appariement déterministe

Le programme "04 - Macro_Appariement.sas" contient 2 macros :

-	Macro "appariesimp" qui fait un chaînage simple basé sur une liste de variable.

-	Macro "appariementcomp" : la macro principale de l'appariement. Cette macro prend en argument le fichier de la base à apparier et une liste de variables. Cette liste sera d'abord utilisée dans la macro "appariesimp" pour faire un chaînage entre les deux bases basant sur toutes les variables. Ensuite cette macro enlèvera une par une des variables de cette liste et utilise la macro "appariesimp" cette fois sur la liste de variables moins d'une variable. Plusieurs termes et leurs combinaisons sont utilisés dans le programme qui seront détaillés par la suite :

    - Total : lorsque le chaînage était fait sur l'ensemble des variables

    - Partiel : lorsque le chaînage est fait en supprimant une des variables

    - Unique : lorsqu'un individu de la base hospitalière est chaîné avec un unique individu de la base INSEE

    - Multiple : lorsqu'un individu de la base hospitalière est chaîné avec plusieurs individus de la base INSEE

    - Inter : lorsque plusieurs individus de la base hospitalière sont chaînés avec un unique individu de la base INSEE

    - Doublon : lorsqu'un individu de la base hospitalière est en doublon sur la même combinaison de variables

    - Non trouvé : lorsqu'un individu de la base hospitalière ne pourra pas être chaîné avec un individu de la base INSEE

Exemple :  

- Si un individu de la base hospitalière est chaîné avec un seul individu de la base INSEE en utilisant toutes les variables, on aura le résultat "Total unique".

- Si un individu de la base hospitalière est chaîné avec un seul individu de la base INSEE en utilisant une variable de moins, on aura le résultat "Partiel unique". La variable supprimée lors de l'appariement sera renseignée dans la case "vardif".

