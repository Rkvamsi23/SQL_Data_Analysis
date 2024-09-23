Use World_Life_Expectancy;

############################################# Data Cleaning #############################################

#Step 1 : Identify Duplicates : Use the combo of Country & Year
select Country , Year , Concat(Country , Year) , count(Concat(Country , Year))
from world_life_expectancy
group by Country , Year , Concat(Country , Year )
having count(Concat(Country , Year)) >1;

#Get the specific Row_ID of duplicates using Windows Function  #
SELECT * from
(select Row_ID ,Concat(Country , Year),
ROW_NUMBER() OVER(PARTITION BY Concat(Country , Year) order by Concat(Country , Year)) as row_num
from world_life_expectancy) as row_table
where row_num >1 ;

# Delete the duplicate Row_IDs #
delete from world_life_expectancy where Row_ID IN ('1251', '2264' ,'2929');

#Step2 : Handling Blank/missing records for Attribute - Country #
select * from world_life_expectancy where Status ='' ;
select * from world_life_expectancy where Status is NULL;

update world_life_expectancy t1
join world_life_expectancy t2
ON t1.Country = t2.Country
SET t1.Status ='Developing'
where t1.Status =''
AND t2.Status <> '';

update world_life_expectancy t1
join world_life_expectancy t2
ON t1.Country = t2.Country
SET t1.Status ='Developed'
where t1.Status =''
AND t2.Status <> '';

#Step3 : Handling missing records for Attribute - Life Expectancy (Selecting first & then Updating it) #

select t1.Country , t1.Year , t1.`Life expectancy` ,
t2.Country , t2.Year , t2.`Life expectancy`,
t3.Country , t3.Year , t3.`Life expectancy`,
ROUND((t2.`Life expectancy` +t3.`Life expectancy`)/2 ,1)
from world_life_expectancy t1
JOIN world_life_expectancy t2 
ON t1.Country = t2.Country
AND t1.Year = t2.Year-1
JOIN world_life_expectancy t3
ON t1.Country = t3.Country
AND t1.Year = t3.Year+1
where t1.`Life expectancy` =''
;

update world_life_expectancy t1
JOIN world_life_expectancy t2 
ON t1.Country = t2.Country
AND t1.Year = t2.Year-1
JOIN world_life_expectancy t3
ON t1.Country = t3.Country
AND t1.Year = t3.Year+1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` +t3.`Life expectancy`)/2 ,1)
where t1.`Life expectancy` =''
;


####################################### EXPLORATORY DATA ANALYSIS ############################################
#1. What are the min and max life expectancies for each Country
#2. Which countries have the highest life increase expectancies
#3. What is the Average life expectancy for Each Year  
#4. What is the Average life expectancy  and average GDP for Each Country
#5. What is the Average Life Expectancy for each Country Status
#6. What is the Average BMI & Avg life expectancy for each Country
#7. What is the Rolling Total Adult Mortality for Country & year


#1.   What are the min and max life expectancies for each Country

select Country,max(`Life expectancy`) , min(`Life expectancy`) from world_life_expectancy
group by Country;

#2. Which countries have the highest life increase expectancies
	
select Country ,max(`Life expectancy`),min(`Life expectancy`),
ROUND(max(`Life expectancy`)- min(`Life expectancy`),2) AS Life_Increase 
from world_life_expectancy
group by Country
having  max(`Life expectancy`) <>0
AND min(`Life expectancy`) <>0
order by Life_Increase asc ;

#3. What is the Average life expectancy for Each Year  

select Year , ROUND(avg(`Life expectancy`),2) as Average_Life_Expectancy from world_life_expectancy
where `Life expectancy` <>0
group by Year
order by Average_Life_Expectancy asc;

#4. What is the Average life expectancy  and average GDP for Each Country

Select Country,ROUND(avg(`Life expectancy`),2)  Average_Life_Expectancy, ROUND(avg(GDP),1) as Average_GDP 
from world_life_expectancy
group by Country
having Average_Life_Expectancy > 0
AND Average_GDP > 0
order by Average_GDP asc ;

#5. What is the Average Life Expectancy for each Country Status

select Status, count(distinct(Country)),ROUND(avg(`Life expectancy`),2)
from world_life_expectancy
group by Status;

#6. What is the Average BMI & Avg life expectancy for each Country
Select Country,ROUND(avg(`Life expectancy`),2)  Average_Life_Expectancy, ROUND(avg(BMI),1) as Average_BMI 
from world_life_expectancy
group by Country
having Average_Life_Expectancy > 0
AND Average_BMI > 0
order by Average_BMI asc ;

#7. What is the Rolling Total Adult Mortality for Country & year

select Country , Year , `Life expectancy`, `Adult Mortality` , 
sum(`Adult Mortality`) OVER( partition by Country order by Year) as Rolling_Total
from world_life_expectancy;