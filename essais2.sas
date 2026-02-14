/*---------------------------------------------------------
  1. Charger la table SAS weather
---------------------------------------------------------*/
libname mydata "";

data weather;
    set mydata.weather;
run;

/*---------------------------------------------------------
  2. Séparation Train/Test (80% / 20%)
---------------------------------------------------------*/
proc surveyselect data=weather out=split seed=12345
    samprate=0.8 outall;
run;

data train test;
    set split;
    if selected = 1 then output train;
    else output test;
run;

/*---------------------------------------------------------
  3. Régression multiple sur TRAIN
     Y = SUNHOUR
     X = toutes les variables numériques sauf SUNHOUR
---------------------------------------------------------*/
proc reg data=train outest=estimates noprint;
    model SUNHOUR = 
        MAX_TEMPERATURE_C
        MIN_TEMPERATURE_C
        WINDSPEED_MAX_KMH
        TEMPERATURE_MORNING_C
        TEMPERATURE_NOON_C
        TEMPERATURE_EVENING_C
        PRECIP_TOTAL_DAY_MM
        HUMIDITY_MAX_PERCENT
        VISIBILITY_AVG_KM
        PRESSURE_MAX_MB
        CLOUDCOVER_AVG_PERCENT
        HEATINDEX_MAX_C
        DEWPOINT_MAX_C
        WINDTEMP_MAX_C
        TOTAL_SNOW_MM
        UV_INDEX
        MONTH
        DAY
    ;
    /* R² du TRAIN */
    output out=train_pred p=pred_train;
run;
quit;

/*---------------------------------------------------------
  4. Appliquer le modèle sur TEST
---------------------------------------------------------*/
proc score data=test score=estimates out=test_pred type=parms;
    var 
        MAX_TEMPERATURE_C
        MIN_TEMPERATURE_C
        WINDSPEED_MAX_KMH
        TEMPERATURE_MORNING_C
        TEMPERATURE_NOON_C
        TEMPERATURE_EVENING_C
        PRECIP_TOTAL_DAY_MM
        HUMIDITY_MAX_PERCENT
        VISIBILITY_AVG_KM
        PRESSURE_MAX_MB
        CLOUDCOVER_AVG_PERCENT
        HEATINDEX_MAX_C
        DEWPOINT_MAX_C
        WINDTEMP_MAX_C
        TOTAL_SNOW_MM
        UV_INDEX
        MONTH
        DAY
    ;
run;

/*---------------------------------------------------------
  5. Calcul du R² TRAIN
---------------------------------------------------------*/
proc corr data=train_pred noprint outp=train_corr;
    var SUNHOUR pred_train;
run;

data train_score;
    set train_corr;
    if _TYPE_="CORR" and _NAME_="SUNHOUR";
    Train_R2 = pred_train**2;
    keep Train_R2;
run;

/*---------------------------------------------------------
  6. Calcul du R² TEST
---------------------------------------------------------*/
proc corr data=test_pred noprint outp=test_corr;
    var SUNHOUR predicted;
run;

data test_score;
    set test_corr;
    if _TYPE_="CORR" and _NAME_="SUNHOUR";
    Test_R2 = predicted**2;
    keep Test_R2;
run;

/*---------------------------------------------------------
  7. Affichage des scores
---------------------------------------------------------*/
title "Scores du modèle de régression multiple (Train/Test)";
proc print data=train_score; run;
proc print data=test_score; run;