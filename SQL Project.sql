/*How many olympics games have been held?*/
SELECT 
    COUNT(DISTINCT Games) AS 'Number of games'
FROM
    olympic_history;

/*List down all Olympics games held so far.*/
SELECT DISTINCT
    Year, Season
FROM
    olympic_history;

/*Mention the total no of nations who participated in each olympics game?*/
SELECT 
    Season, Year, COUNT(DISTINCT (Team)) AS 'Nation Count'
FROM
    olympic_history
GROUP BY Year , Season
ORDER BY Year;

/*Which year saw the highest and lowest no of countries participating in olympics*/
SELECT DISTINCT
    Year, Season
FROM
    olympic_history;
    
 /* Identify the sport which was played in all summer olympics.*/
SELECT DISTINCT
    Sport
FROM
    olympic_history
WHERE
    Games LIKE '%Summer%';
 
 /*Which Sports were just played only once in the olympics.*/
 SELECT 
    COUNT(DISTINCT (Games)), sport
FROM
    olympic_history
GROUP BY sport
HAVING COUNT(DISTINCT (Games)) = 1;
 
 /*Fetch the total no of sports played in each olympic games.*/
 SELECT 
    Games, COUNT(DISTINCT (Sport)) AS no_of_sports
FROM
    olympic_history
GROUP BY Games;

 /*Fetch oldest athletes to win a gold medal*/
 WITH cte_gold_age as (
SELECT ID, Name, Sex, Age,
DENSE_RANK() over( order by Age desc) as rnk
FROM olympic_history
WHERE Medal = 'Gold' )
SELECT cte_gold_age.ID, cte_gold_age.Name, cte_gold_age.Sex, cte_gold_age.Age 
FROM cte_gold_age WHERE rnk = 1;

/*Retrieve the total number of orders placed.*/
SELECT 
    COUNT(order_id) AS 'total orders'
FROM
    orders;

 /*Find the Ratio of male and female athletes participated in all olympic games*/
 WITH male_count as
 (SELECT COUNT(Sex) AS 'male_count', Games
 FROM olympic_history
 WHERE Sex = 'M'
GROUP BY Games),

 female_count as
(SELECT COUNT(Sex) AS 'female_count', Games
FROM olympic_history
WHERE Sex = 'F'
GROUP BY Games)

SELECT * FROM male_count
JOIN female_count 
ON male_count.Games = female_count.Games;

/* Fetch the top 5 athletes who have won the most gold medals.*/
SELECT 
    name, COUNT(medal) AS gold_medal
FROM
    olympic_history
WHERE
    Medal = 'Gold'
GROUP BY name
ORDER BY gold_medal
LIMIT 5;

/* Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).*/
SELECT 
    name, COUNT(medal) AS medal_count
FROM
    olympic_history
WHERE
    Medal IS NOT NULL
GROUP BY name
ORDER BY medal_count
LIMIT 5;

 /*Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won*/
 SELECT 
    Team, COUNT(Medal) AS 'Medals_won'
FROM
    olympic_history
WHERE
    Medal IS NOT NULL
GROUP BY Team
ORDER BY Medals_won DESC
LIMIT 5;
 
 /* List down total gold, silver and bronze medals won by each country corresponding to each olympic games.*/
 WITH cte_gold as
 (SELECT Games, Team, COUNT(Medal) as 'Gold_Medal_Count'
 FROM olympic_history
 WHERE Medal = 'Gold'
 GROUP BY Games,Team),
 cte_silver as
 (SELECT Games,Team, COUNT(Medal) as 'Silver_Medal_Count'
 FROM olympic_history
 WHERE Medal = 'Silver'
 GROUP BY Games, Team),
 cte_bronze as
 (SELECT Games, Team, COUNT(Medal) as 'Bronze_Medal_Count'
 FROM olympic_history
 WHERE Medal = 'Bronze'
 GROUP BY Games, Team)
 SELECT a.Games,a.Team,a.Gold_Medal_Count as 'Gold_Count',
 b.Silver_Medal_Count as 'Silver_Medal_Count',
 c.Bronze_Medal_Count as 'Bronze_Medal_Count'
 FROM cte_gold as a
 INNER JOIN cte_silver as b
 ON a.Team = b.Team AND a.Games = b.Games
 JOIN cte_bronze as c
 ON a.Team = c.Team AND a.Games = b.Games
 ORDER BY Games, Team DESC;

/*List down total gold, silver and bronze medals won by each country*/
with cte_gold as (
                  select  Team,  count(Medal) as gold_medal_cnt
                  from olympic_history where Medal = 'Gold'
                  group by Team   ),

cte_silver as (
               select  Team,  count(Medal) as silver_medal_cnt from olympic_history
               where Medal = 'Silver'
               group by Team  ),

cte_bronze as (
              select  Team,  count(Medal) as bronze_medal_cnt from olympic_history
              where Medal = 'Bronze'
              group by Team   )
select a.Team, a.gold_medal_cnt as gold_count, b.silver_medal_cnt as silver_cnt, c.bronze_medal_cnt as bronze_cnt
from cte_gold as a
inner join cte_silver as b
on a.Team = b.Team 
join cte_bronze as c
on a.Team = c.Team
order by 2 desc;

  /*Identify which country won the most gold, most silver and most bronze medals in each olympic games.*/
 WITH cte_gold AS
 (SELECT *, ROW_NUMBER() OVER (partition by Games ORDER BY Gold_Medal_Count DESC) as r_n_gold
 FROM(
 SELECT Games,Team,COUNT(Medal) as 'Gold_Medal_Count'
 FROM olympic_history
 WHERE Medal = 'Gold'
 GROUP BY Games,Team ) as a),

 cte_silver AS
 (SELECT *,ROW_NUMBER() OVER(partition by Games ORDER BY Silver_Medal_Count DESC)as r_n_silver
 FROM
 (SELECT Games,Team, COUNT(Medal) as 'Silver_Medal_Count'
 FROM olympic_history
 WHERE Medal = 'Silver'
 GROUP BY Games, Team) as b),
 
 cte_bronze AS 
 (SELECT *, ROW_NUMBER() OVER (partition by Games ORDER BY Bronze_Medal_Count DESC) as r_n_bronze
 FROM
 (SELECT Games,Team,COUNT(Medal) as 'Bronze_Medal_Count'
 FROM olympic_history
 WHERE Medal ='Bronze'
 GROUP BY Games,Team) as c)
 SELECT p.Games,
 CONCAT(p.Team,'-',p.Gold_Medal_Count) as Max_Gold,
 CONCAT(q.Team,'-',q.Silver_Medal_Count) as Max_Silver,
 CONCAT(r.Team,'-',r.Bronze_Medal_Count) as Max_Bronze
 FROM cte_gold as p
 JOIN cte_silver as q
 ON p.Games = q.Games AND p.Team = q.Team
 JOIN cte_bronze as r
 ON p.Games = r.Games AND p.Team = r.Team
 WHERE p.r_n_Gold =1  AND r.r_n_Bronze = 1 AND q.r_n_Silver = 1; 
 
 /*Which countries have never won gold medal but have won silver or bronze medals?*/
WITH countries_with_gold AS 
(SELECT DISTINCT Team
FROM olympic_history
WHERE Medal = 'Gold')

SELECT DISTINCT Team
FROM olympic_history
WHERE Medal IN ('Silver','Bronze')
AND Team NOT IN(SELECT Team FROM countries_with_gold);

/*In which Sport/event, India has won highest medals?*/
WITH t1 AS
(SELECT Sport, COUNT(1) as 'Highest_Score'
FROM olympic_history
WHERE Medal <> 'N/A'
AND Team = 'India'
GROUP BY Sport
ORDER BY Highest_Score DESC),
t2 AS 
(SELECT *,RANK() OVER (ORDER BY Highest_Score DESC) as rnk
FROM t1)
SELECT sport, Highest_Score
FROM t2
WHERE rnk = 1;

/*Break down all Olympic games where India won medal for Hockey and how many medals in each olympic games*/
SELECT 
    Team, sport, COUNT(Medal) AS 'Medals_Won', Games
FROM
    olympic_history
WHERE
    Team = 'India' AND sport = 'Hockey'
        AND Medal <> 'N/A'        
GROUP BY Team , Games , sport
ORDER BY Medals_Won DESC;


