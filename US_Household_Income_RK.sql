############################################# Data Cleaning #############################################
Use US_Household_Income;
select * from ushouseholdincome;
select * from ushouseholdincome_statistics;

# Check for Duplicates in ushouseholdincome table
select id , count(id) from ushouseholdincome
group by id
having count(id) >1 
order by id;

#Get the specific Row_ID of duplicates using Windows Function  #
SELECT * from
(select row_id , id,
ROW_NUMBER() OVER( PARTITION BY id order by id) as row_num
from ushouseholdincome ) as row_table
where row_num >1;


# Delete the duplicate row_id #
DELETE from ushouseholdincome where row_id IN(
SELECT row_id from
(select row_id ,
ROW_NUMBER() OVER( PARTITION BY id order by id) as row_num
from ushouseholdincome ) as row_table
where row_num >1);

#Checking Duplicates for ushouseholdincome_statistics #
select id , count(id) from ushouseholdincome_statistics group by id having count(id) >1;

# FIXING State  Name Spelling - Georgia
select distinct State_name from ushouseholdincome;

update ushouseholdincome
set State_name = 'Georgia' where State_name ='georia';

# Updating Place blank value to 'Autaugaville' #
update ushouseholdincome
set Place = 'Autaugaville' where Place ='';


# Updating Type to Borough #
select  Type , count(Type)from ushouseholdincome
group by Type
order by 1;

Update ushouseholdincome set Type ='Borough' where Type= 'Boroughs';

# Checking 0 or blank vaues for ALand & AWater

select ALand , AWater from ushouseholdincome 
where  AWater =0 OR AWater = ''or AWater is NULL;

select ALand , AWater from ushouseholdincome 
where ALand =0 OR ALand = ''or ALand is NULL; 

####################################### EXPLORATORY DATA ANALYSIS ############################################
#1.  Wich State has the largest ALand & AWater ?

Select State_name , SUM(ALand) , SUM(AWater) from ushouseholdincome
group by State_name
order by 2  desc
LIMIT 10;

#2.Which 10 States have the highest Average Income & Average Median ?

Select u1.State_Name , ROUND(AVG(u2.Mean),2) as Avg_Income, ROUND(AVG(u2.Median),2) as Avg_Median from ushouseholdincome u1
JOIN ushouseholdincome_statistics u2
ON u1.id = u2.id
where u2.Mean <>0 AND 
u2.Median <> 0
group by u1.State_Name
order by 2 desc
LIMIT 10;

#3.  Which Top 20 Types have the highest Average income & Avg Median ?
Select u1.Type , count(u1.Type), ROUND(AVG(u2.Mean),2) as Avg_Income, ROUND(AVG(u2.Median),2) as Avg_Median from ushouseholdincome u1
JOIN ushouseholdincome_statistics u2
ON u1.id = u2.id
where u2.Mean <>0 AND 
u2.Median <> 0
group by u1.Type
order by count(u1.Type) desc
LIMIT 20;

#4. Which CITY has the highest average Income ?
Select u1.State_Name, u1.City , ROUND(AVG(u2.Mean),2) as Avg_Income, ROUND(AVG(u2.Median),2) as Avg_Median from ushouseholdincome u1
JOIN ushouseholdincome_statistics u2
ON u1.id = u2.id
where u2.Mean <>0 AND 
u2.Median <> 0
group by u1.State_Name , u1.City
order by 3 desc
LIMIT 20;

