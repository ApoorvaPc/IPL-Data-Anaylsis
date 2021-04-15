-- Create DataBase

drop database if exists IPL_database;
Create database if not exists IPL_database;

use IPL_database;
-- Create Two Data Tables

-- Table 1 
drop table if exists IPL_Matches;
create table IPL_Matches (
ID	INT NOT NULL,
City VARCHAR(255) NOT NULL,
Year INT NOT NULL,
Player_of_the_Match	VARCHAR(255) NOT NULL,
Venue VARCHAR(255) NOT NULL,
Team_1	VARCHAR(255) NOT NULL,
Team_2	VARCHAR(255) NOT NULL,
Toss_winner	VARCHAR(255) NOT NULL,
Toss_decision	VARCHAR(255) NOT NULL,
Winner	VARCHAR(255) NOT NULL,
Result	VARCHAR(255) NOT NULL,
Eliminator VARCHAR(255) NOT NULL   );

select * from IPL_Matches;

-- Table 2
drop table if exists IPL_Ball_by_Ball;
create table IPL_Ball_by_Ball (
ID	INT NOT NULL,
Inning INT NOT NULL,
Overs INT NOT NULL,
Ball INT NOT NULL,
Batsman	VARCHAR(255) NOT NULL,
Non_stricker VARCHAR(255) NOT NULL,
Bowler	VARCHAR(255) NOT NULL,
Batsman_runs INT NOT NULL,	
Extra_runs	INT NOT NULL,
Total_runs	INT NOT NULL,
Is_wicket BIT NOT NULL,
Dismissal_kind	VARCHAR(255) NOT NULL,
Player_dismissed VARCHAR(255) NOT NULL,
Fielder	VARCHAR(255) NOT NULL,
Extras_type	VARCHAR(255) NOT NULL,
Batting_team VARCHAR(255) NOT NULL,
Bowling_team VARCHAR(255) NOT NULL      )

select *  from IPL_Ball_by_Ball;

-- Task 1: Each Venue with Number of matches and Win % when Batting and Bowling first

select 
    Venue,
    city as City,
    count(Venue) as Number_of_matches,
    round(count(case 
                when Toss_winner = Team_1 and Toss_decision = 'bat' and Winner = Team_1 then  1
                when Toss_winner = Team_2 and Toss_decision = 'bat' and Winner = Team_2 then 1
				when Toss_winner = Team_1 and Toss_decision = 'field' and Winner = Team_2 then 1 
                when Toss_winner = Team_2 and Toss_decision = 'field' and Winner = Team_1 then 1
                else null end)/count(Venue),2) as Win_Perc_When_Batting_first,
	round(count(case 
                when Toss_winner = Team_1 and Toss_decision = 'field' and Winner = Team_1 then 1 
                when Toss_winner = Team_2 and Toss_decision = 'field' and Winner = Team_2 then 1
				when Toss_winner = Team_1 and Toss_decision = 'bat' and Winner = Team_2 then 1
                when Toss_winner = Team_2 and Toss_decision = 'bat' and Winner = Team_1 then 1
                else null end)/count(Venue),2) as Win_Perc_When_Bowling_first
	from ipl_matches
    group by Venue;
    
    
-- TASK  2: TEAM PERFORMANCE FOR ALL THE YEARS IN TERMS OF RUNS AND WICKETS
-- Create Temporay table to sum runs of team for each year
Drop table if exists Team_Runs;
create temporary table Team_Runs(
SELECT 
   b.Year,
   a.Batting_team as Team,
   sum(a.Total_runs) as Runs
from ipl_ball_by_ball a 
inner join ipl_matches b on a.id = b.id
group by  b.year, a.Batting_team);

-- Create Temporay table to sum wickets of team for each year
Drop table if exists Team_Wickets;
create temporary table Team_Wickets(
Select
             b.Year,
             a.Bowling_team as Team,
             sum(a.is_wicket) as Wickets
       from ipl_ball_by_ball a 
       inner join ipl_matches b on a.id = b.id 
       group by  b.year, a.Bowling_team);
       
select 
     r.year,
     r.Team,
     r.Runs as Runs,
     w.Wickets as Wickets
from Team_Runs r join Team_Wickets w on r.year = w.year and r.Team = w.Team;


-- Task - 3: Economy_rate and No_of_wickets of Each Bowler 

select 
    Bowler,
    sum(is_wicket) as no_of_wickets,
    round((count(ball)/6),1) as Overs,
    round((sum(Batsman_runs) + sum(Extra_runs))/(count(Ball)/6),2) as Economy_Rate
from ipl_ball_by_ball
where Extra_runs in ('wides', 'noballs')
group by bowler
having (count(ball)/6) > 50
order by Economy_Rate asc;

-- Task  4: Type of Dismissals

select 
   Dismissal_kind,
   count(Dismissal_kind) as Count
from ipl_ball_by_ball 
where Dismissal_kind != 'Not_allowed'
group by Dismissal_kind
order by Count desc;


-- TASK 5: Orange cap holder and Purple cap holder


-- Create table to retrive Runs Scored by all Batsman
drop table if exists Runs_scored_by_all_Batsman;
create table Runs_scored_by_all_Batsman
select 
    im.year,
    ib.batsman ,
    sum(ib.batsman_runs) as total_runs,
    ib.bowler,
    sum(ib.Is_wicket) as No_of_wickets
from ipl_ball_by_ball ib left join ipl_matches im
on ib.id= im.id 
group by im.year, ib.Batsman , ib.Bowler
order by year;

-- Create table to retrive Wickets taken by all Bowler
drop table if exists Wickets_taken_by_All_Bowlers;
create table Wickets_taken_by_All_Bowlers
select 
    im.year,
    ib.bowler,
    sum(ib.Is_wicket) as No_of_wickets
from ipl_ball_by_ball ib left join ipl_matches im
on ib.id= im.id 
group by im.year, ib.Bowler
order by year;

-- Select Top Run scorer for each Year

SELECT 
    a.year, a.batsman, a.total_runs
FROM
    Runs_scored_by_all_Batsman a
        INNER JOIN
    (SELECT 
        year, MAX(total_runs) AS total_runs
    FROM
        Runs_scored_by_all_Batsman
    GROUP BY year) b ON a.year = b.year
        AND a.total_runs = b.total_runs;
 -- Select Top wicket Taker for each Year
 
SELECT 
    a.year, a.bowler, a.No_of_wickets
FROM
    wickets_taken_by_all_bowlers a
        INNER JOIN
    (SELECT 
        year, MAX(No_of_wickets) AS No_of_wickets
    FROM
        wickets_taken_by_all_bowlers
    GROUP BY year) b ON a.year = b.year AND a.No_of_wickets = b.No_of_wickets;



   