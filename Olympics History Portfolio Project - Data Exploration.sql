/* 
Olympics History Data Exploration

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions

*/


-- 1.Query: Total numbers of olympic games

SELECT COUNT(distinct games) AS total_olypic_games
FROM `olympics.olympics_history`



-- 2.Query: Listed down all olympic games

SELECT DISTINCT Year, Season, City
FROM `olympics.olympics_history`
ORDER BY Year

-- 3. Query: Total number of nations participated in each olympic game

with all_countries as
(SELECT Games, nr.string_field_1
FROM `olympics.olympics_history` oh
JOIN `olympics.noc_regions` nr ON nr.string_field_0 = oh.NOC
GROUP BY Games, nr.string_field_1)
SELECT Games, COUNT(1) AS toal_countries
FROM all_countries
GROUP BY Games
Order By Games


-- 4.Query: Sports that were played in all summer olympic games

-- Total Number of summer olympic games
 
WITH t1 AS
(SELECT COUNT(DISTINCT Games) AS total_games
FROM `olympics.olympics_history`
WHERE Season = "Summer"),

-- Found each sport played 

t2 AS
(SELECT DISTINCT Games, Sport
FROM `olympics.olympics_history` 
WHERE season = 'Summer'),

-- Count the games each sport played

t3 AS
(SELECT Sport, COUNT(Games) AS no_of_games
FROM t2
GROUP BY Sport)
SELECT * 
FROM t3

-- JOIN table 1 with 3 where both numbers are equal

JOIN t1 on t1.total_games = t3.no_of_games


-- 5.Query: Rank Top 5 athletes who won the most gold medals

-- Top 5 athletes who won the most gold medals

WITH t1 AS 
(SELECT Name,COUNT(Medal) AS total_medals
FROM `olympics.olympics_history`
WHERE Medal = "Gold"
GROUP BY Name
ORDER BY total_medals DESC),

-- Ranked the athletes

t2 AS
(SELECT *, DENSE_RANK() OVER(ORDER BY total_medals DESC) AS rnk
FROM t1)
SELECT *
FROM t2
WHERE rnk <=5
ORDER BY rnk


-- 6. Query: 5 most successful (number of medals) countries in olympics

-- Joined both tables to get the country name and counted the medals

WITH t1 AS
(SELECT nr.string_field_1 AS Country, COUNT(1) AS total_medals
FROM `olympics.olympics_history` oh
JOIN `olympics.noc_regions` nr ON nr.string_field_0 = oh.NOC 
WHERE Medal <> "NA"
GROUP BY nr.string_field_1
ORDER BY total_medals DESC),

-- Ranked the 5 most successful countries

t2 AS
(SELECT *, dense_rank() over(Order By total_medals DESC) AS rnk
FROM t1)
SELECT *
FROM t2
WHERE rnk <=5
ORDER BY rnk


-- 7. Query: Oldest athletes who won a gold medal

WITH temp AS
(SELECT Name,Sex, CAST(CASE WHEN age = "NA" then "0" else age end as int) AS Age,
sport, event, medal
FROM `olympics.olympics_history`),

-- Ranked to number 1 to find out the oldest athletes

ranking AS 
(SELECT*, rank()OVER(ORDER BY age DESC) as rnk
from temp
WHERE medal = "Gold")
SELECT*
FROM ranking
WHERE rnk = 1