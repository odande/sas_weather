/*---------------------------------------------------------
  1. Chargement de la table SAS existante
     (Assure-toi que weather.sas7bdat est dans WORK ou dans une lib définie)
---------------------------------------------------------*/
libname mydata "";   /* <-- adapte le chemin */

data weather;
    set mydata.weather;
run;

/*---------------------------------------------------------
  2. Vérification rapide de la structure
---------------------------------------------------------*/
proc contents data=weather; run;

/*---------------------------------------------------------
  3. Régression linéaire :
     MAX_TEMPERATURE_C = f(MIN_TEMPERATURE_C)
---------------------------------------------------------*/
proc reg data=weather;
    model MAX_TEMPERATURE_C = MIN_TEMPERATURE_C;
    title "Régression linéaire : Température Max ~ Température Min";
run;
quit;

/*---------------------------------------------------------
  4. Graphique : nuage de points + droite de régression
---------------------------------------------------------*/
proc sgplot data=weather;
    scatter x=MIN_TEMPERATURE_C y=MAX_TEMPERATURE_C /
        markerattrs=(symbol=circlefilled color=blue size=8);
    reg x=MIN_TEMPERATURE_C y=MAX_TEMPERATURE_C /
        lineattrs=(color=red thickness=2);
    xaxis label="Température minimale (°C)";
    yaxis label="Température maximale (°C)";
    title "Relation entre Températures Min et Max (2019)";
run;