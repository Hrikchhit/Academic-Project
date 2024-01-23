/* libararies */
libname data '/home/u63506514/Intro/final';
/* load */
data data.Drivers;
  /* path skip 2*/
  infile '/home/u63506514/Intro/final/Drivers.csv' 
    delimiter=',' dsd missover
    firstobs=2;
  informat 
    Report_Number $50.
    Local_Case_Number $9.
    Agency_Name $50.
    ACRS_Report_Type $50.
    Crash_Date_Time $20.
    Route_Type $50.
    Road_Name $50.
    Cross_Street_Type $20.
    Cross_Street_Name $50.
    Municipality $20.
    Related_Non_Motorist $20.
    Collision_Type $50.
    Weather $20.
    Surface_Condition $20.
    Light $20.
    Traffic_Control $30.
    Driver_Substance_Abuse $30.
    Non_Motorist_Substance_Abuse $20.
    Person_ID $40.
    Driver_At_Fault $10.
    Injury_Severity $30.
    Circumstance $20.
    Driver_Distracted_By $50.
    Drivers_License_State $20.
    Vehicle_ID $40.
    Vehicle_Damage_Extent $30.
    Vehicle_First_Impact_Location $30.
    Vehicle_Second_Impact_Location $30.
    Vehicle_Body_Type $30.
    Vehicle_Movement $30.
    Vehicle_Continuing_Dir $10.
    Vehicle_Going_Dir $10.
    Speed_Limit best32.
    Driverless_Vehicle $4.
    Parked_Vehicle $4.
    Vehicle_Year 4.
    Vehicle_Make $20.
    Vehicle_Model $20.
    Equipment_Problems $50.
    Latitude best32.
    Longitude best32.
    Location $35.
  ;

  input 
    Report_Number
    Local_Case_Number
    Agency_Name
    ACRS_Report_Type
    Crash_Date_Time
    Route_Type
    Road_Name
    Cross_Street_Type
    Cross_Street_Name
    Municipality
    Related_Non_Motorist
    Collision_Type
    Weather
    Surface_Condition
    Light
    Traffic_Control
    Driver_Substance_Abuse
    Non_Motorist_Substance_Abuse
    Person_ID
    Driver_At_Fault
    Injury_Severity
    Circumstance
    Driver_Distracted_By
    Drivers_License_State
    Vehicle_ID
    Vehicle_Damage_Extent
    Vehicle_First_Impact_Location
    Vehicle_Second_Impact_Location
    Vehicle_Body_Type
    Vehicle_Movement
    Vehicle_Continuing_Dir
    Vehicle_Going_Dir
    Speed_Limit 
    Driverless_Vehicle
    Parked_Vehicle
    Vehicle_Year
    Vehicle_Make
    Vehicle_Model
    Equipment_Problems
    Latitude
    Longitude
    Location;

run;


data data.Incidents;
  /* path */
  infile '/home/u63506514/Intro/final/incident.csv' 
         delimiter=',' dsd missover
    		firstobs=2; /* Skip the header row */
 
  informat
    Report_Number $50.
    Local_Case_Number $50.
    Agency_Name $50.
    ACRS_Report_Type $50.
    Crash_Date_Time $50.
    Hit_Run $5.
    Route_Type $50.
    Mile_Point best32./* Assuming Mile_Point is numeric, no informat needed */
    Mile_Point_Direction $10.
    Lane_Direction $50.
    Lane_Number best12. /* Use informat if necessary, adjust as needed */
    Lane_Type $50.
    Direction $50.
    Distance best12. /* Use informat if necessary, adjust as needed */
    Distance_Unit $50.
    Road_Grade $50.
    NonTraffic $50.
    Road_Name $50.
    Cross_Street_Type $50.
    Cross_Street_Name $50.
    Municipality $50.
    Related_Non_Motorist $50.
    At_Fault $50.
    Collision_Type $50.
    Weather $50.
    Surface_Condition $50.
    Light $50.
    Traffic_Control $50.
    Driver_Substance_Abuse $50.
    Non_Motorist_Substance_Abuse $50.
    First_Harmful_Event $50.
    Second_Harmful_Event $50.
    Fixed_Object_Struck $50.
    Junction $50.
    Intersection_Type $50.
    Intersection_Area $50.
    Road_Alignment $50.
    Road_Condition $50.
    Road_Division $50.
    Latitude $50.
    Longitude $50.
    Location $50.;
        
  /* define var */
  input
    Report_Number 
    Local_Case_Number 
    Agency_Name 
    ACRS_Report_Type 
    Crash_Date_Time 
    Hit_Run 
    Route_Type 
    Mile_Point 
    Mile_Point_Direction 
    Lane_Direction 
    Lane_Number
    Lane_Type 
    Direction 
    Distance
    Distance_Unit 
    Road_Grade 
    NonTraffic 
    Road_Name 
    Cross_Street_Type 
    Cross_Street_Name 
    Municipality 
    Related_Non_Motorist 
    At_Fault 
    Collision_Type 
    Weather 
    Surface_Condition 
    Light 
    Traffic_Control 
    Driver_Substance_Abuse 
    Non_Motorist_Substance_Abuse 
    First_Harmful_Event 
    Second_Harmful_Event 
    Fixed_Object_Struck 
    Junction 
    Intersection_Type 
    Intersection_Area 
    Road_Alignment 
    Road_Condition 
    Road_Division 
    Latitude 
    Longitude
    Location ; 
run;

/*Joints*/
proc sql;
create table data.merged as 
select D.*,
I.Hit_Run, 
I.Mile_Point_Direction, 
I.Lane_Direction , 
I.Lane_Number, 
I.Lane_Type , 
I.Direction, 
I.Distance, 
I.Distance_Unit,  
I.Road_Grade, 
I.NonTraffic, 
I.First_Harmful_Event, 
I.Second_Harmful_Event, 
I.Fixed_Object_Struck, 
I.Junction, 
I.Intersection_Type, 
I.Intersection_Area, 
I.Road_Alignment, 
I.Road_Condition, 
I.Road_Division
from data.Incidents as I
inner join data.Drivers as D
on I.Report_Number = D.Report_Number;
quit;

/* change format start */
data data.merged;
    set data.merged;
    
    /* convert format */
    datetime_value = input(Crash_Date_Time, anydtdtm20.);

    /* extract date */
    date_value = datepart(datetime_value);

    /* extract time */
    time_value = timepart(datetime_value);

    /* extract specific */
    month = month(date_value);
    day = day(date_value);
    year = year(date_value);

    /* convert 24 hrs */
    time_24hr = put(time_value, time8.);

    drop datetime_value date_value time_value;
run;
/* change format end */


/* check cols */
proc contents data=data.merged; 
run;

/* export */
PROC EXPORT DATA=data.merged 
            OUTFILE='/home/u63506514/Intro/final/merged_data.csv' 
            DBMS=csv REPLACE;
    PUTNAMES=YES;
RUN;

/* 1 */
/* vehical damage vs speed */
data Q1;
set data.Drivers;

/* remove UNKOWN from vech damage */
if Vehicle_Damage_Extent ne 'UNKNOWN';

/* select specific column */
keep Vehicle_Damage_Extent Speed_Limit;
run;
/*rows 159376*/
proc sql;
select count(*) as RowCount
from Q1;
quit;

/*exclude missing*/
data CQ1;
set Q1;
/* exclude missing*/
if not missing(Vehicle_Damage_Extent) and not missing(Speed_Limit);
run;
/*rows 159376*/
proc sql;
select count(*) as RowCount
from CQ1;
quit;

/*1 Finished vech damage and extend*/
proc sgplot data=CQ1;
vbar Vehicle_Damage_Extent / response=Speed_Limit stat=mean datalabel;
xaxis label="Vehicle Damage Extent";
yaxis label="Mean Speed Limit";
run;


/* 2 */
/* vehical damage vs day light */
proc sgplot data=data.Drivers;
where Light in ('DAYLIGHT', 'DARK LIGHTS ON');
vbar Light / group=Vehicle_Damage_Extent groupdisplay=cluster datalabel;
xaxis label="Light";
yaxis label="Count";
run;

/* 3 */
/* hit n Run vs at fault */
proc sgplot data=data.Incidents;
  vbar Hit_Run / group=At_Fault groupdisplay=cluster datalabel;
  xaxis label="Hit and Run";
  yaxis label="Count";
run;
 

/* 4 */
/*hit n run  and substance */
proc sgplot data=data.merged;
where Driver_Substance_Abuse in ('NONE DETECTED', 'ALCOHOL PRESENT');
  vbar Hit_Run / group=Driver_Substance_Abuse groupdisplay=cluster datalabel;
  xaxis label="Hit and Run";
  yaxis label="Incidents Count";
run;

 
/* 5 */
/* speed limit and road codition */
/* fix order */
/* remove na unkown and others */
proc means data=data.merged mean noprint;
    var Speed_Limit;
    class Road_Condition;
    output out=data.MeanSpeedByCondition mean(Speed_Limit)=MeanSpeed;
run;
proc sgplot data=data.MeanSpeedByCondition;
    vbar Road_Condition / response=MeanSpeed stat=mean datalabel;
    yaxis label="Mean Speed Limit";
    xaxis label="Road Condition" display=(nolabel);
    title "Mean Speed Limit by Road Condition";
run;

/* 6 */
/* vehical damage and injury */
proc sgplot data=data.merged;
    where (Vehicle_Damage_Extent in ('DISABLING', 'FUNCTIONAL'));
    vbar Injury_Severity / group=Vehicle_Damage_Extent groupdisplay=cluster datalabel ;
    xaxis label="Driver substance abuse";
    yaxis label="Count";
run;

/* 7 boxplot added
/* speed limit mean of each injury */
proc means data=data.merged mean noprint;
    var Speed_Limit;
    class Injury_Severity;
    output out=data.MeanSpeedBySeverity mean(Speed_Limit)=MeanSpeed;
run;
/* sorting */
proc sort data=data.MeanSpeedBySeverity;
    by MeanSpeed;
run;

/* plot */
proc sgplot data=data.MeanSpeedBySeverity;
    vbar Injury_Severity / response=MeanSpeed stat=mean datalabel grouporder=DATA;
    yaxis label="Mean Speed Limit";
    xaxis label="Injury Severity" display=(nolabel);
    title "Mean Speed Limit by Injury Severity";
run;

/* boxplot use this*/
proc sgplot data=data.merged;
    vbox Speed_Limit / category=Injury_Severity;
    yaxis label="Speed Limit";
    xaxis label="Injury Severity" display=(nolabel);
    title "Distribution of Speed Limit by Injury Severity";
run;



/* 8 */
/* For Vehicle_Movement */
proc freq data=data.merged;
    tables Vehicle_Movement / noprint out=UniqueVehicleMovement (drop=percent);
run;

/* For Driver_At_Fault */
proc freq data=data.merged;
    tables Driver_At_Fault / noprint out=UniqueDriverAtFault (drop=percent);
run;

/* Vehicle_Movement vs  Driver_At_Fault */
proc sgplot data=data.merged;
    where (Driver_At_Fault in ('Yes', 'No'))
    and (Vehicle_Movement in ('MOVING CONSTANT SPEED', 'SLOWING OR STOPPING'));
    vbar Driver_At_Fault / group=Vehicle_Movement groupdisplay=cluster datalabel ;
    xaxis label="Driver at fault";
    yaxis label="Count";
    title "Vehicle movements and Driver at fault";
run;




/* 9 */
proc sgplot data=data.merged;
    where (Vehicle_Damage_Extent in ('DISABLING', 'FUNCTIONAL'));
    vbar year / group=Vehicle_Damage_Extent groupdisplay=cluster datalabel ;
    xaxis label="Year";
    yaxis label="Count";
    title "Vehicle damage by Years";
run;

/* 10 */
/* sql aggret */
proc sql;
    create table data.Aggregated as 
    select 
        /* convert hrs */
        input(substr(time_24hr, 1, 2), 2.) as Hour,
        Injury_Severity,
        count(Injury_Severity) as Severity_Count
    from data.merged_updated
    group by Hour, Injury_Severity
    order by Hour, Injury_Severity;
quit;

/* Plot the line chart */
proc sgplot data=data.Aggregated;
    series x=Hour y=Severity_Count / group=Injury_Severity break;
    xaxis label="Time (Rounded to nearest hour)";
    yaxis label="Count of Injury Severity";
    keylegend / location=inside position=topright across=1;
    title "Count of Injury Severity by Time of Day";
run;


