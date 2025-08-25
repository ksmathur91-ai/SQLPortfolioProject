use namastesql
select * from Credit_card_transactions

/* Adding column to table and add number data to column 
alter table Credit_card_transactions add new_index int

WITH cte AS (
    SELECT new_index, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM Credit_card_transactions
)
UPDATE cte
SET new_index = rn;


select card_type, count(new_index) as No_of_customers
from Credit_card_transactions
group by card_type

Silver		6840
Signature	6447
Gold		6367
Platinum	6398

*/
--tenure
/*
select min(date) as startof_date, max(date) as endof_date, DATEDIFF(MONTH, min(date), max(date)) as time_tenure 
from Credit_card_transactions

2013-10-04	2015-05-26 19 months
*/

-- expense types
select distinct exp_type 
from Credit_card_transactions
/*
Entertainment
Food
Bills
Fuel
Travel
Grocery
*/
--Gender ratio
SELECT Gender, COUNT(*) AS Count, avg(cast(amount as bigint)) as total_amount
FROM Credit_card_transactions
GROUP BY Gender

--Male, female count based on expense_type
SELECT exp_type, 
    COUNT(CASE WHEN Gender = 'M' THEN 1 END) AS MaleCount,
    COUNT(CASE WHEN Gender = 'F' THEN 1 END) AS FemaleCount
FROM Credit_card_transactions
group by exp_type

select city, top 5 count(city) 
from Credit_card_transactions
group by city




--write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

with cte as(
select city, sum(amount) as citywise_spends
FROM Credit_card_transactions
group by city
) 

select top 5 city, citywise_spends, (citywise_spends*100.00/(select sum(cast(citywise_spends as bigint))from cte)) as percentage_contribution
from cte
group by city, citywise_spends
order by percentage_contribution desc
---


--write a query to print highest spend month and amount spent in that month for each card type
with spent as(
select card_type, DATEPART(Year, date) as Y, DATEPART(month, date) as m, sum(amount) as spent_amount
from Credit_card_transactions
group by card_type, DATEPART(Year, date), DATEPART(month, date)
 )
, find_max as(
select card_type, Y, M, spent_amount, rank() over (partition by card_type order by spent_amount desc) as rn
from spent
)

select * from find_max
where rn=1

/*write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)*/

with cum_s as(
select *, sum(cast(amount as bigint)) over (partition by card_type order by date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as cum_sum
from Credit_card_transactions
)
, rnk as(
select *, rank() over (partition by card_type order by cum_sum) as rn
from cum_s where cum_sum>=1000000
)

select * from rnk where rn=1

--write a query to find city which had lowest percentage spend for gold card type
select t1.city, (t2.gold_card_spent/t1.all_card_spent)*1.0 as per_spent_gold
from
(
select city, card_type,  sum(amount) as all_card_spent
from Credit_card_transactions
group by city, card_type) t1
inner join (
select city, sum(amount) as gold_card_spent
from Credit_card_transactions
where card_type='Gold'
group by city
) t2 on t1.city=t2.city

--write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

with city_exp as(
select city, exp_type, sum(amount) as total_exp_amt
from Credit_card_transactions
group by city, exp_type
), rank_exp as(
select city, exp_type, total_exp_amt, rank() over (partition by city order by total_exp_amt) as a_rk, rank() over (partition by city order by total_exp_amt desc) as d_rk
from city_exp
)
select city, min(case when a_rk=1 then exp_type end) as min_exp, min(case when d_rk=1 then exp_type end) as max_exp
from rank_exp
group by city


--write a query to find percentage contribution of spends by females for each expense type each_exp/total_exp

select exp_type, (sum(case when gender='F' then amount else 0 end)*100.0/sum(amount)) as female_contributuion  
from Credit_card_transactions
group by exp_type



--which card and expense type combination saw highest month over month growth in Jan-2014
with each_month_amount as(
select card_type, exp_type, Year(date) as Y, MONTH(date) as M, sum(amount) as expense_amount
from Credit_card_transactions
group by card_type, exp_type, Year(date), MONTH(date)
)
, lag_f as (
select *, Lag(expense_amount, 1, 0) over (partition by card_type, exp_type Order by Y,M) as last_month_exp
from each_month_amount
)
, growth as(
select *, (expense_amount-last_month_exp) as mom_growth
from lag_f
where Y='2014' and M='1'
)
select top 1 *, rank() over (order by mom_growth desc) as rk
from growth

--During weekends which city has highest total spend to total no of transcations ratio 

select top 1 city ,  sum(amount)*1.0/count(*) as highest_total_weekend
from Credit_card_transactions
where DATENAME(weekday, date) in ('Sunday', 'Saturday')
group by city
order by highest_total_weekend desc

--which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as(
select  city, date, ROW_NUMBER() over (partition by city order by date) as rn
from Credit_card_transactions
),
dateset as(
select city, case when rn=1 then date end as first_date, case when rn=500 then date end as last_date, rn
from cte 
),
first_last_date as(
select city, MIN(first_date) first_trans_date, MAX(last_date) as last_trans_date
from dateset
group by city
)
, cities_with_days as ( 
select city, DATEDIFF(day, first_trans_date, last_trans_date) as No_of_days
from first_last_date
)

select top 1 *
from cities_with_days
where No_of_days is not null
order by No_of_days 




















