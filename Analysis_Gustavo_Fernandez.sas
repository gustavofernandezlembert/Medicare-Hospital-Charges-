
libname gus "E:\SASUniversityEdition\myfolders\sasuser.v94";
run;


/* Create a table named Medicare_NY_DRG689 by Selecting Kidney and Urinary Tract Infections for patients with major
complications or comorbidity DRG-689 from hospitals in the State of New York 
from the Table named "Medicare" wich is just a rename of (Inpatient Charge Data FY 2018) dataset */


proc sql;
create table gus.Medicare_NY_DRG689 as
select *
from Gus.MEDICARE
WHERE DRG_DESC LIKE '%689%' and State_Desc='NY';
quit;


/* link the Medicare_NY_DRG689 with the RUCA using common ZIP_CODES to obtain the inforation of metropolitan status of those hospitals
then create a Table with this information named Medicare_NY_DRG689_WRUCA*/

proc sql;
create table gus.Medicare_NY_DRG689_WRUCA as
select* 
from gus.Medicare_NY_DRG689, gus.RUCA
where Medicare_NY_DRG689.Facility_ZIP_CODE=RUCA.ZIP_CODE;
quit;

/* Create a new variable called Metropolitan_Status where 

if  1<= RUCA1 <=3* then Metropolitan_Status= "Metropolitan"
else if RUCA1=99 then Metropolitan_Status="Not coded: Census tract has zero population and no rural-urban identifier information"
else Metropolitan_Status="Non-Metropolitan" */

data gus.Medicare_NY_DRG689_WRUCA;
set gus.Medicare_NY_DRG689_WRUCA;
if  1<= RUCA1 <=3 THEN Metropolitan_Status='Metropolitan';
else if RUCA1=99 THEN Metropolitan_Status='Not coded: Census tract has zero population and no rural-urban identifier information'
else Metropolitan_Status='Non-Metropolitan';
run;

/*lets see what is the distribution of Metro vs Non_Metro or if there is any with Not coded */

proc freq data=gus.Medicare_NY_DRG689_WRUCA;
table Metropolitan_Status;
run;

/* to fnd out how hospital charges are associated with the metropolitan_status in the state
 I want to test if there is a significant difference in the means of the mean_covered_charges between
hospital in the metropolitan group and hospitals in the Non_Metropolitan group  

Independent sample ttest is used*/

proc ttest data=gus.Medicare_NY_DRG689_WRUCA;
class Metropolitan_Status;
var Mean_Covered_charges;
run;

/* investigate two outliers */

proc sql;
select *
from gus.Medicare_NY_DRG689_WRUCA
order by Mean_Covered_Charges Desc;
quit;
