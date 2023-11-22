-- My first steps in SQL
-- Mis primeros pasos en SQL




-- I am a beginner in using SQL and I found the following page as a way to put my acquired knowledge into practice to perform queries in SQL
-- Soy principiante en el uso de SQL y encontré la siguiente página como una forma de poner en práctica mis conocimientos adquiridos para realizar consultas en SQL
-- Link: https://techtfq.com/blog/practice-writing-sql-queries-using-real-dataset

-- This page shares you a database with two tables that contain data related to the Olympic games
-- Esta pagina te comparte una base de datos con dos tablas que contienen datos relacionados a los juegos olímpicos

-- The page contains the queries it wants you to perform, a display of the result, and a link to view the SQL query for resolution.
-- La página contiene las consultas que quiere que realices, una visualización del resultado y un enlace para ver la consulta de SQL para la resolución.

-- For query No. 4 I had to be guided by the solution shared on the page. I had no relationship with the "WITH" and "CONCAT" clauses and this solution helped me understand them better
-- Para la consulta No 4 tuve que guiarme con la solución compartida en la página. Yo no tenía relación con las cláusulas "WITH" y "CONCAT" y esta solución me ayudó a entenderlas mejor

-- For the rest of the queries with which I had difficulties, for example No: 10, 14 and 16, I used the search for information on the internet and help from chatgpt. I learned more about clauses CAST, CASE WHEN and OVER
-- Para el resto de consultas con las que tuve dificultades, por ejemplo las No: 10, 14 y 16, me valí de la búsqueda de información en internet y ayuda de chatgpt. Aprendí más sobre las cláusulas CAST, CASE WHEN y OVER


-- The first thing I do is completely observe the two tables that I have
-- Lo primero que hago es observar por completo las dos tablas que tengo
Select * 
from Olimpic_project_practice..athlete_events$

Select * 
from Olimpic_project_practice..noc_regions$

-- LET'S STARTED!! / EMPECEMOS!!

--1) How many olympics games have been held? / ¿Cuántos juegos olímpicos se han celebrado?
Select count(distinct(Games)) AS Total_Olimpic_Games
from Olimpic_project_practice..athlete_events$
-- Both the winter and summer Olympic games are taken into account. / Tomamos en cuenta los juegos olímpicos de invierno y verano

-- 2) List down all Olympics games held so far. / Enumerar todos lo juegos olímpicos celebrados
Select distinct(Year), Season, City
from Olimpic_project_practice..athlete_events$
order by Year

-- 3) Mention the total no of nations who participated in each olympics game? / ¿Mencione el número total de naciones que participaron en cada juego olímpico?
select Games, count(distinct region) as total_countries
from Olimpic_project_practice..athlete_events$ as ath
join Olimpic_project_practice..noc_regions$ as reg on ath.NOC = reg.NOC
Group by games
order by Games

-- 4) Which year saw the highest and lowest no of countries participating in olympics / ¿En qué año se registró el número más alto y más bajo de países que participaron en los Juegos Olímpicos?
With all_countries as (
	select Games, reg.region
	from Olimpic_project_practice..athlete_events$ as ath
	join Olimpic_project_practice..noc_regions$ as reg on ath.NOC = reg.NOC
	group by Games, reg.region
), tot_countries as (
	Select Games, count(region) as total_countries
	from all_countries
	group by Games
)
Select distinct 
CONCAT(first_value(games) over(order by total_countries), ' - ', first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
CONCAT(first_value(games) over(order by total_countries desc), ' - ', first_value(total_countries) over(order by total_countries desc)) Highest_Countries
from tot_countries


-- 5) Which nation has participated in all of the olympic games / ¿Qué naciones han participado en todos los juegos olímpicos?

with tot_games as (
	select count(distinct games) as total_games
	from Olimpic_project_practice..athlete_events$
), all_countries as(
	select reg.region, count(distinct reg.region) as total_no_games
	from Olimpic_project_practice..athlete_events$ as ath
	join Olimpic_project_practice..noc_regions$ as reg on ath.NOC = reg.NOC
	group by reg.region, Games
), participation as (
	select region, sum(total_no_games) as total_participation
	from all_countries
	group by region
) 
select *
from participation
join tot_games on tot_games.total_games = participation.total_participation
order by 1;

-- 6) Identify the sport which was played in all summer olympics. 
with tot_games as (
	select count(distinct games) as total_games
	from Olimpic_project_practice..athlete_events$
	where Season = 'Summer'
), type_sport as (
	select Sport, count(distinct Sport) as sport_total
	from Olimpic_project_practice..athlete_events$
	group by Sport, Games
), sport_by_game as (
	select sport, SUM(sport_total) as sport_sum
	from type_sport
	group by Sport
)
Select *
from sport_by_game 
join tot_games on tot_games.total_games= sport_by_game.sport_sum

-- 7) Which Sports were just played only once in the olympics.
with t_sport as (
	Select Games, sport, count(distinct Sport) as count_sport
	from Olimpic_project_practice..athlete_events$
	group by Games, Sport
), one_sport as ( 
	select Sport, sum(count_sport) as cant_sport
	from t_sport
	group by Sport
) 
select sport, cant_sport
from one_sport
where cant_sport = 1

-- 8) Fetch the total no of sports played in each olympic games. / Obtenga el número total de deportes jugados en cada juego olímpico.
Select Games, count (distinct Sport) as total_sports
from Olimpic_project_practice..athlete_events$
group by Games
order by total_sports desc

-- 9) Fetch oldest athletes to win a gold medal / Busca a los atletas de mayor edad para ganar una medalla de oro.

with oldest as (
	Select *
	from Olimpic_project_practice..athlete_events$
	where Medal = 'Gold' and Age <> 'NA' 
) Select *
from oldest
where Age = (select max(Age) from oldest)

--10) Find the Ratio of male and female athletes participated in all olympic games. / Encuentre la proporción de atletas masculinos y femeninos que participaron en todos los juegos olímpicos.

with p_female as (
	Select sex, COUNT(1) as proportion_female
	from Olimpic_project_practice..athlete_events$
	group by Sex
	having Sex = 'F'
), p_male as (
	Select sex, COUNT(1) as proportion_male
	from Olimpic_project_practice..athlete_events$
	group by Sex
	having Sex = 'M'
) Select round(cast(proportion_male as float)/cast(proportion_female as float), 2) as Ratio
from p_female, p_male

-- 11) Fetch the top 5 athletes who have won the most gold medals. / Busque los 5 mejores atletas que han ganado la medalla de oro

WITH golden_athletes AS (
    SELECT name, COUNT(name) AS total_GoldMedals
    FROM Olimpic_project_practice..athlete_events$
    WHERE Medal = 'Gold'
    GROUP BY name
)
SELECT name, total_GoldMedals
FROM golden_athletes
WHERE total_GoldMedals IN (
    SELECT DISTINCT TOP 5 total_GoldMedals
    FROM golden_athletes
    ORDER BY total_GoldMedals DESC
    )

order by total_GoldMedals desc

-- 12) Fetch the top 5 athletes who have won the most medals (gold/silver/bronze). / Busca los 5 mejores atletas que hayan ganado más medallas (oro/plata/bronce).

WITH golden_athletes AS (
    SELECT name, COUNT(name) AS total_Medals
    FROM Olimpic_project_practice..athlete_events$
    WHERE Medal <> 'NA'
    GROUP BY name
)
SELECT name, total_Medals
FROM golden_athletes
WHERE total_Medals IN (
	SELECT DISTINCT TOP 5 total_Medals
    FROM golden_athletes
    ORDER BY total_Medals DESC)

Order by total_Medals desc

-- 13) Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won. / Busque los 5 países más exitosos en los Juegos Olímpicos. El éxito se define por el número de medallas ganadas.
with country_medals as (
	Select reg.region, count(medal) as cant_medals
	from Olimpic_project_practice..athlete_events$ as atl
	join Olimpic_project_practice..noc_regions$ as reg on atl.NOC = reg.NOC
	where atl.Medal <> 'NA'
	group by reg.region
	
) Select region, cant_medals
from country_medals
where cant_medals In (
	SELECT DISTINCT TOP 5 cant_medals
    FROM country_medals 
	order by cant_medals desc
)
order by cant_medals desc

-- 14)  List down total gold, silver and bronze medals won by each country. Enumere el total de medallas de oro, plata y bronce ganadas por cada país.

Select reg.region, count(Medal on (medal = 'Gold')) as cant_medals
from Olimpic_project_practice..athlete_events$ as atl
join Olimpic_project_practice..noc_regions$ as reg on atl.NOC = reg.NOC

SELECT reg.region, 
       SUM(CASE WHEN atl.medal = 'Gold' THEN 1 ELSE 0 END) as Gold,
       SUM(CASE WHEN atl.medal = 'Silver' THEN 1 ELSE 0 END) as Silver,
       SUM(CASE WHEN atl.medal = 'Bronze' THEN 1 ELSE 0 END) as Bronze
FROM Olimpic_project_practice..athlete_events$ as atl
JOIN Olimpic_project_practice..noc_regions$ as reg ON atl.NOC = reg.NOC
GROUP BY reg.region
order by Gold desc

-- 15) List down total gold, silver and bronze medals won by each country corresponding to each olympic games. / Enumere el total de medallas de oro, plata y bronce ganadas por cada país correspondiente a cada juego olímpico.
SELECT atl.Games, reg.region, 
       SUM(CASE WHEN atl.medal = 'Gold' THEN 1 ELSE 0 END) as Gold,
       SUM(CASE WHEN atl.medal = 'Silver' THEN 1 ELSE 0 END) as Silver,
       SUM(CASE WHEN atl.medal = 'Bronze' THEN 1 ELSE 0 END) as Bronze
FROM Olimpic_project_practice..athlete_events$ as atl
JOIN Olimpic_project_practice..noc_regions$ as reg ON atl.NOC = reg.NOC
GROUP BY atl.games, reg.region
order by Games, reg.region

-- 16) Identify which country won the most gold, most silver and most bronze medals in each olympic games. / Identifica qué país ganó más medallas de oro, más plata y más bronce en cada juego olímpico

WITH top_winners as (
	SELECT atl.Games, reg.region, 
		   SUM(CASE WHEN atl.medal = 'Gold' THEN 1 ELSE 0 END) as Gold,
		   SUM(CASE WHEN atl.medal = 'Silver' THEN 1 ELSE 0 END) as Silver,
		   SUM(CASE WHEN atl.medal = 'Bronze' THEN 1 ELSE 0 END) as Bronze
	FROM Olimpic_project_practice..athlete_events$ as atl
	JOIN Olimpic_project_practice..noc_regions$ as reg ON atl.NOC = reg.NOC
	GROUP BY atl.games, reg.region
) Select distinct Games, 
	CONCAT(first_value(region) over(PARTITION BY Games order by games, Gold desc), ' - ', first_value(Gold) over(PARTITION BY Games order by games, gold desc)) as Max_Gold,
	CONCAT(first_value(region) over(PARTITION BY Games order by games, Silver desc), ' - ', first_value(Silver) over(PARTITION BY Games order by games, silver desc)) as Max_Silver,
	CONCAT(first_value(region) over(PARTITION BY Games order by games, Bronze desc), ' - ', first_value(Bronze) over(PARTITION BY Games order by games, Bronze desc)) as Max_Bronze	
From top_winners


-- 17)  Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games. / Identifica qué país ganó más medallas de oro, más plata, más medallas de bronce y más medallas en cada juego olímpico.

WITH top_winners as (
	SELECT atl.Games, reg.region, 
		   SUM(CASE WHEN atl.medal = 'Gold' THEN 1 ELSE 0 END) as Gold,
		   SUM(CASE WHEN atl.medal = 'Silver' THEN 1 ELSE 0 END) as Silver,
		   SUM(CASE WHEN atl.medal = 'Bronze' THEN 1 ELSE 0 END) as Bronze,
		   SUM(CASE WHEN atl.medal <> 'NA' THEN 1 ELSE 0 END) as Medals
	FROM Olimpic_project_practice..athlete_events$ as atl
	JOIN Olimpic_project_practice..noc_regions$ as reg ON atl.NOC = reg.NOC
	GROUP BY atl.games, reg.region
) Select distinct Games, 
	CONCAT(first_value(region) over(PARTITION BY Games order by games, Gold desc), ' - ', first_value(Gold) over(PARTITION BY Games order by games, gold desc)) as Max_Gold,
	CONCAT(first_value(region) over(PARTITION BY Games order by games, Silver desc), ' - ', first_value(Silver) over(PARTITION BY Games order by games, silver desc)) as Max_Silver,
	CONCAT(first_value(region) over(PARTITION BY Games order by games, Bronze desc), ' - ', first_value(Bronze) over(PARTITION BY Games order by games, Bronze desc)) as Max_Bronze,
	CONCAT(first_value(region) over(PARTITION BY Games order by games, Medals desc), ' - ', first_value(Medals) over(PARTITION BY Games order by games, Medals desc)) as Max_Medals
From top_winners

-- 18) Which countries have never won gold medal but have won silver/bronze medals? / ¿Qué países nunca han ganado medallas de oro pero sí medallas de plata/bronce?

with total_country as (
	SELECT reg.region as Country, 
			SUM(CASE WHEN atl.medal = 'Gold' THEN 1 ELSE 0 END) as Gold,
			SUM(CASE WHEN atl.medal = 'Silver' THEN 1 ELSE 0 END) as Silver,
			SUM(CASE WHEN atl.medal = 'Bronze' THEN 1 ELSE 0 END) as Bronze
	FROM Olimpic_project_practice..athlete_events$ as atl
	JOIN Olimpic_project_practice..noc_regions$ as reg ON atl.NOC = reg.NOC
	GROUP BY reg.region 
)
Select *
From total_country
where Gold = 0 and (Silver <> 0 or Bronze <>0)

-- 19) In which Sport/event, India has won highest medals. / En qué deporte/evento, India ha ganado la mayor cantidad de medallas
With c_sports as (
	select reg.region,Sport, COUNT(medal) as count_medals
	from Olimpic_project_practice..athlete_events$ as atl
	JOIN Olimpic_project_practice..noc_regions$ as reg ON atl.NOC = reg.NOC
	GROUP BY reg.region, Sport
	having region = 'India'
)
Select distinct first_value(Sport) over(order by count_medals desc) as Sport, first_value(count_medals) over(order by count_medals desc) as total_medals
from c_sports

-- 20) Break down all olympic games where India won medal for Hockey and how many medals in each olympic games / Desglose todos los juegos olímpicos en los que India ganó medallas de hockey y cuántas medallas en cada juego olímpico.
	
select reg.region, Sport, games, COUNT(medal) as count_medals
from Olimpic_project_practice..athlete_events$ as atl
JOIN Olimpic_project_practice..noc_regions$ as reg ON atl.NOC = reg.NOC
GROUP BY region, sport, Games
having region = 'India' and Sport = 'Hockey'
order by count_medals desc


