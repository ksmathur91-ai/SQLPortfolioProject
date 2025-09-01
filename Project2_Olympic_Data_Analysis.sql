--Using CSV to upload two data files from tasks 
--modified datatype of athlete_id from tinyint to int (as was showing error) in athelete_events table
--modified datatype of athlete name column to varchar(max), height & weight as 'Null' for all missing values in columns in athelete table (1,35,571)rows
--clean medal 'NA' to NULL in athlete_events column name 'medal'

use namastesql

select * from athlete_events e
join athletes a on e.athlete_id=a.id
where a.team='India'
order by year asc


select top 100 * from athletes

--1 which team has won the maximum gold medals over the years.

select top 1 a.team,  COUNT(distinct event) as events_in_olympics
from athlete_events e
inner join athletes a
on e.athlete_id=A.id
where medal = 'Gold'
group by a.team
order by events_in_olympics desc

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

with cte as(
select team, e.YEAR,  COUNT(distinct event) as silver_medals, RANK() over (partition by team order by count(distinct event) desc) as rn
from athlete_events e
inner join athletes a
on e.athlete_id=A.id
where medal = 'Silver'
group by a.team, e.year
)

select team, SUM(silver_medals) total_silver_medals, max(case when rn=1 then year end) as year_of_max_silver
from cte
group by team


--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

select athlete_id, COUNT(*) as only_gold_winners
from athlete_events 
where athlete_id not in (select athlete_id from athlete_events where medal in ('Silver', 'Bronze'))
and medal = 'Gold'
group by athlete_id
order by only_gold_winners desc

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

with cte as(
select YEAR, name, count(medal) as Gold_count
from athlete_events e
join athletes a on e.athlete_id=a.id
where medal = 'Gold'
group by year, name

)
, cte2 as(
select *, rank() over (partition by Year order by Gold_count desc) as rn
from cte
)

select Year, Gold_count, STRING_AGG(name, ',') as Atheletes
from cte2
where rn=1
group by year, Gold_count


--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,event

with cte as(
select  event, year, medal,ROW_NUMBER() over (partition by medal order by year asc) as rn
from athlete_events e
join athletes a on
e.athlete_id=a.id
where a.team='India'
and medal is not null
)

select distinct medal, YEAR, event
from cte where rn=1


--6 find players who won gold medal in summer and winter olympics both.

select *
from athlete_events

select athlete_id
from athlete_events
where medal='Gold'
group by athlete_id
having COUNT(distinct season)>=2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select a.name, year
from athlete_events e 
join athletes a on e.athlete_id=a.id
where medal is not null
group by a.name, year
having count(distinct medal)=3


--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with cte as(
select name,event, year, lag(year,1) over(partition by name,event order by year ) as prev_year, LEAD(year,1) over(partition by name,event order by year ) as next_year
from athlete_events e
join athletes a on
e.athlete_id=a.id
where medal='Gold' and year>=2000 and season = 'Summer'
group by name, event, year
)

select * from cte
where year between prev_year and next_year




