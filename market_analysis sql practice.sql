SELECT * FROM market_analysis.market_analysis;
/*Alter Table market_analysis.market_analysis
RENAME COLUMN ï»¿unified_id to unified_id;*/

#Check for missing values in each column.
SELECT 
  SUM(CASE WHEN `city` IS NULL THEN 1 ELSE 0 END) AS missing_city,
  SUM(CASE WHEN `nightly rate` IS NULL THEN 1 ELSE 0 END) AS missing_rate
FROM market_analysis.market_analysis;

#Find duplicate records (based on City, Host_Type, and Nightly_Rate).
SELECT city, Host_Type, `nightly rate`, COUNT(*) 
FROM market_analysis.market_analysis
GROUP BY city, Host_Type, `nightly rate`
HAVING COUNT(*) > 1;

# Find the average nightly rate and average occupancy across all cities
select round(avg(`nightly rate`),2) as avg_nightly_rate , round(avg(occupancy),2) as avg_occupancy
from market_analysis.market_analysis;

# Show top 4 cities by total revenue.
select city, sum(revenue) as "Total Revenue"
from market_analysis.market_analysis
group by city
order by "Total Revenue" desc
limit 5;

# Calculate average nightly rate per host type.
select host_type, round(avg(`nightly rate`),2) as avg_nightly_rate
from market_analysis.market_analysis
group by host_type
order by avg_nightly_rate desc;


/*# Alter table to have month and date column
Alter Table market_analysis.market_analysis
Add Column Year VarChar(20),
Add Column Months VarChar(20);

Update market_analysis.market_analysis
Set Year= SUBSTRING_INDEX(month, '-', 1),
Months=substring_index(month,'-',-1);

ALTER TABLE market_analysis.market_analysis DROP COLUMN Year, DROP COLUMN `Months`;*/

# Compare average occupancy by month to identify peak months
with cte as (select *,SUBSTRING_INDEX(month, '-', 1) AS year,
   SUBSTRING_INDEX(month, '-', -1) AS months
    from market_analysis.market_analysis)
select months, round(avg(occupancy),2) as avg_occupancy
from cte
group by months
order by months;

# Find the city with the highest proportion of long-stay customers (>7 days).
select city,
count(case when `length stay`>7 then 1 end )*100.0/count(*) as long_stay_put
from market_analysis.market_analysis
group by city
order by long_stay_put desc;

# Analyze average revenue by stay length segment (short <3, medium 3–7, long >7).
select 
case when `length stay` <3 then "short 3"
when `length stay`>=3 and `length stay`<=7 then "medium 3-7"
when  `length stay` >7 then "long >7" 
end as `length segment`,
avg(revenue) as avg_revenue
from market_analysis.market_analysis
group by `length segment`;
#order by avg_revenue desc;


# Compare revenue trends between “2–5 Units” and “Single Unit” host types.
select host_type, round(avg(revenue),2) as revenue_trends
from market_analysis.market_analysis
where host_type in ("2-5 Units" , "Single Owners")
group by host_type;


# Identify cities that are underperforming — high nightly rates but low occupancy.
select city , round(avg(`nightly rate`),3) as avg_nightly_rate,
round(avg(`occupancy`),3) as avg_occupancy
from market_analysis.market_analysis
group by city
having avg(`nightly rate`) > (select avg(`nightly rate`) from market_analysis.market_analysis)
AND avg(`occupancy`)<(select avg(`occupancy`) from market_analysis.market_analysis);


# Find correlation trend between lead time and occupancy.
SELECT SUBSTRING_INDEX(month, '-', -1) AS months,
  ROUND(AVG(`lead time`), 2) AS avg_lead,
  ROUND(AVG(occupancy), 2) AS avg_occupancy
FROM market_analysis.market_analysis
GROUP BY SUBSTRING_INDEX(month, '-', -1) 
ORDER BY avg_lead;

# Identify which city and host type combination performs best overall.
select city, host_type,
round(avg(revenue),2),
round(avg(occupancy),2)
FROM market_analysis.market_analysis
group by city, host_type; 


# Rank top-performing listings by revenue per occupied night.
select *,  ROUND(revenue / (occupancy * `length stay` / 100), 2) as revenue_per_night
FROM market_analysis.market_analysis
order by revenue_per_night desc;
