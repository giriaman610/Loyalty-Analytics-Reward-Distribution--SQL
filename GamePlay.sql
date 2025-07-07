
--Importing All the required data files in form of CSV into the postgresql database

--1.Importing User Gameplay Data
DROP TABLE IF EXISTS User_Gameplay_data
CREATE TABLE User_Gameplay_data(
User_ID	integer,
Games_Played integer,
Datetime TIMESTAMP
)

--1.Importing User Deposit_Amount_Data
DROP TABLE IF EXISTS Deposit_Amount_Data
CREATE TABLE Deposit_Amount_Data(
User_ID	integer,
Datetime TIMESTAMP,
deposit_Amount   integer
)

--1.Importing User Withdrawal_Amount_data

DROP TABLE IF EXISTS Withdrawal_Amount_data
CREATE TABLE Withdrawal_Amount_data(
User_ID	integer,
Datetime TIMESTAMP,
withdrawal_Amount  integer
)

--now calculating loyality points for each category in repsective tables

--1 deposit  amount table

ALTER TABLE Deposit_Amount_Data ADD COLUMN loyalty_points NUMERIC;
UPDATE Deposit_Amount_Data
SET loyalty_points = 0.01 * "deposit_amount";

--calculating loyalty points withdrawal amount table

ALTER TABLE Withdrawal_Amount_data ADD COLUMN loyalty_points NUMERIC;
UPDATE Withdrawal_Amount_data
SET loyalty_points = 0.005 * "withdrawal_amount";

-- Gameplay data table

ALTER TABLE User_Gameplay_data ADD COLUMN loyalty_points NUMERIC;
UPDATE User_Gameplay_data
SET loyalty_points = 0.2 * "games_played";


--Part A - Calculating loyalty points

--1. Find Playerwise Loyalty points earned by Players in the following slots:-

--a. Calculating total loyalty points for 2nd October Slot S1

CREATE TEMP TABLE deposit_slot_s2 AS
SELECT
  user_id,
  SUM(loyalty_points) AS deposit_points,
  COUNT(*) AS num_deposit
FROM Deposit_Amount_Data
WHERE datetime >= '2022-10-02 00:00:00' AND datetime < '2022-10-02 12:00:00'
GROUP BY user_id;

CREATE TEMP TABLE withdrawal_slot_s1 AS
SELECT 
  user_id,
  SUM(loyalty_points) AS withdrawal_points,
  COUNT(*) AS num_withdrawal
FROM Withdrawal_Amount_data
WHERE datetime >= '2022-10-02 00:00:00' AND datetime < '2022-10-02 12:00:00'
GROUP BY user_id;

CREATE TEMP TABLE gameplay_slot_s1 AS
SELECT 
  user_id,
  SUM(loyalty_points) AS game_points,
  SUM("games_played") AS games_played
FROM User_Gameplay_data
WHERE datetime >= '2022-10-02 00:00:00' AND datetime < '2022-10-02 12:00:00'
GROUP BY user_id;

DROP TABLE IF EXISTS slot1_bonus_point
CREATE TEMP TABLE slot1_bonus_point as

WITH deposits AS (
  SELECT user_id, COUNT(*) AS num_deposit
  FROM Deposit_Amount_Data
  WHERE datetime >= '2022-10-02 00:00:00' AND datetime < '2022-10-02 12:00:00'
  GROUP BY user_id
  ORDER BY 2 desc
),
withdrawals AS (
  SELECT user_id, COUNT(*) AS num_withdrawal
  FROM Withdrawal_Amount_data
  WHERE datetime >= '2022-10-02 00:00:00' AND datetime < '2022-10-02 12:00:00'
  GROUP BY user_id
  ORDER BY 2 desc
)
SELECT
  COALESCE(d.user_id, w.user_id) AS user_id,
  COALESCE(d.num_deposit, 0) AS num_deposit,
  COALESCE(w.num_withdrawal, 0) AS num_withdrawal,
  0.001 * GREATEST(COALESCE(d.num_deposit, 0) - COALESCE(w.num_withdrawal, 0), 0) AS bonus_points
FROM deposits d
FULL OUTER JOIN withdrawals w ON d.user_id = w.user_id;


SELECT 
  COALESCE(d.user_id, w.user_id, g.user_id, b.user_id) AS user_id,
  COALESCE(d.deposit_points, 0) AS deposit_points,
  COALESCE(w.withdrawal_points, 0) AS withdrawal_points,
  COALESCE(g.game_points, 0) AS game_points,
  COALESCE(b.bonus_points, 0) AS bonus_points,
  (
    COALESCE(d.deposit_points, 0) +
    COALESCE(w.withdrawal_points, 0) +
    COALESCE(g.game_points, 0) +
    COALESCE(b.bonus_points, 0)
  ) AS total_loyalty_points
FROM deposit_slot_s2 d
FULL OUTER JOIN withdrawal_slot_s1 w ON d.user_id = w.user_id
FULL OUTER JOIN gameplay_slot_s1 g ON COALESCE(d.user_id, w.user_id) = g.user_id
FULL OUTER JOIN slot1_bonus_point b ON COALESCE(d.user_id, w.user_id, g.user_id) = b.user_id
ORDER BY total_loyalty_points DESC

--b. Calculating total loyalty points for 16nd October Slot S2---------------------------------------

CREATE TEMP TABLE deposit_slot_s2 AS
SELECT 
  user_id,
  SUM(loyalty_points) AS deposit_points,
  COUNT(*) AS num_deposit
FROM Deposit_Amount_Data
WHERE datetime >= '2022-10-16 12:00:00' AND datetime < '2022-10-17 00:00:00'
GROUP BY user_id;


CREATE TEMP TABLE withdrawal_slot_s2 AS
SELECT 
  user_id,
  SUM(loyalty_points) AS withdrawal_points,
  COUNT(*) AS num_withdrawal
FROM Withdrawal_Amount_data
WHERE datetime >= '2022-10-16 12:00:00' AND datetime < '2022-10-17 00:00:00'
GROUP BY user_id;


CREATE TEMP TABLE gameplay_slot_s2 AS
SELECT 
  user_id,
  SUM(loyalty_points) AS game_points,
  SUM("games_played") AS games_played
FROM User_Gameplay_data
WHERE datetime >= '2022-10-16 12:00:00' AND datetime < '2022-10-17 00:00:00'
GROUP BY user_id;


DROP TABLE IF EXISTS slot2_bonus_point
CREATE TEMP TABLE slot2_bonus_point as

WITH deposits AS (
  SELECT user_id, COUNT(*) AS num_deposit
  FROM Deposit_Amount_Data
  WHERE datetime >= '2022-10-16 12:00:00' AND datetime < '2022-10-17 00:00:00'
  GROUP BY user_id
  ORDER BY 2 desc
),
withdrawals AS (
  SELECT user_id, COUNT(*) AS num_withdrawal
  FROM Withdrawal_Amount_data
WHERE datetime >= '2022-10-16 12:00:00' AND datetime < '2022-10-17 00:00:00'
  GROUP BY user_id
  ORDER BY 2 desc
)
SELECT
  COALESCE(d.user_id, w.user_id) AS user_id,
  COALESCE(d.num_deposit, 0) AS num_deposit,
  COALESCE(w.num_withdrawal, 0) AS num_withdrawal,
  0.001 * GREATEST(COALESCE(d.num_deposit, 0) - COALESCE(w.num_withdrawal, 0), 0) AS bonus_points
FROM deposits d
FULL OUTER JOIN withdrawals w ON d.user_id = w.user_id;


SELECT 
  COALESCE(d.user_id, w.user_id, g.user_id, b.user_id) AS user_id,
  COALESCE(d.deposit_points, 0) AS deposit_points,
  COALESCE(w.withdrawal_points, 0) AS withdrawal_points,
  COALESCE(g.game_points, 0) AS game_points,
  COALESCE(b.bonus_points, 0) AS bonus_points,
  (
    COALESCE(d.deposit_points, 0) +
    COALESCE(w.withdrawal_points, 0) +
    COALESCE(g.game_points, 0) +
    COALESCE(b.bonus_points, 0)
  ) AS total_loyalty_points
FROM deposit_slot_s2 d
FULL OUTER JOIN withdrawal_slot_s2 w ON d.user_id = w.user_id
FULL OUTER JOIN gameplay_slot_s2 g ON COALESCE(d.user_id, w.user_id) = g.user_id
FULL OUTER JOIN slot2_bonus_point b ON COALESCE(d.user_id, w.user_id, g.user_id) = b.user_id
ORDER BY total_loyalty_points DESC

--b. Calculating total loyalty points for 18nd October Slot S1---------------------------------------

CREATE TEMP TABLE deposit_slot_18oct_s1  AS
SELECT 
  user_id,
  SUM(loyalty_points) AS deposit_points,
  COUNT(*) AS num_deposit
FROM Deposit_Amount_Data
WHERE datetime >= '2022-10-18 00:00:00' AND datetime < '2022-10-18 12:00:00'
GROUP BY user_id;


CREATE TEMP TABLE withdrawal_slot_18oct_s1  AS
SELECT 
  user_id,
  SUM(loyalty_points) AS withdrawal_points,
  COUNT(*) AS num_withdrawal
FROM Withdrawal_Amount_data
WHERE datetime >= '2022-10-18 00:00:00' AND datetime < '2022-10-18 12:00:00'
GROUP BY user_id;


CREATE TEMP TABLE gameplay_slot_18oct_s1  AS
SELECT 
  user_id,
  SUM(loyalty_points) AS game_points,
  SUM("games_played") AS games_played
FROM User_Gameplay_data
WHERE datetime >= '2022-10-18 00:00:00' AND datetime < '2022-10-18 12:00:00'
GROUP BY user_id;


DROP TABLE IF EXISTS bonus_slot_18oct_s1 
CREATE TEMP TABLE bonus_slot_18oct_s1  as

WITH deposits AS (
  SELECT user_id, COUNT(*) AS num_deposit
  FROM Deposit_Amount_Data
WHERE datetime >= '2022-10-18 00:00:00' AND datetime < '2022-10-18 12:00:00'
  GROUP BY user_id
  ORDER BY 2 desc
),
withdrawals AS (
  SELECT user_id, COUNT(*) AS num_withdrawal
  FROM Withdrawal_Amount_data
WHERE datetime >= '2022-10-18 00:00:00' AND datetime < '2022-10-18 12:00:00'
  GROUP BY user_id
  ORDER BY 2 desc
)
SELECT
  COALESCE(d.user_id, w.user_id) AS user_id,
  COALESCE(d.num_deposit, 0) AS num_deposit,
  COALESCE(w.num_withdrawal, 0) AS num_withdrawal,
  0.001 * GREATEST(COALESCE(d.num_deposit, 0) - COALESCE(w.num_withdrawal, 0), 0) AS bonus_points
FROM deposits d
FULL OUTER JOIN withdrawals w ON d.user_id = w.user_id;


SELECT 
  COALESCE(d.user_id, w.user_id, g.user_id, b.user_id) AS user_id,
  COALESCE(d.deposit_points, 0) AS deposit_points,
  COALESCE(w.withdrawal_points, 0) AS withdrawal_points,
  COALESCE(g.game_points, 0) AS game_points,
  COALESCE(b.bonus_points, 0) AS bonus_points,
  (
    COALESCE(d.deposit_points, 0) +
    COALESCE(w.withdrawal_points, 0) +
    COALESCE(g.game_points, 0) +
    COALESCE(b.bonus_points, 0)
  ) AS total_loyalty_points
FROM deposit_slot_18oct_s1  d
FULL OUTER JOIN withdrawal_slot_18oct_s1 w ON d.user_id = w.user_id
FULL OUTER JOIN gameplay_slot_18oct_s1 g ON COALESCE(d.user_id, w.user_id) = g.user_id
FULL OUTER JOIN bonus_slot_18oct_s1 b ON COALESCE(d.user_id, w.user_id, g.user_id) = b.user_id
ORDER BY total_loyalty_points DESC


--b. Calculating total loyalty points for 26nd October Slot S2---------------------------------------

CREATE TEMP TABLE deposit_slot_26oct_s2   AS
SELECT 
  user_id,
  SUM(loyalty_points) AS deposit_points,
  COUNT(*) AS num_deposit
FROM Deposit_Amount_Data
WHERE datetime >= '2022-10-26 12:00:00' AND datetime < '2022-10-27 00:00:00'
GROUP BY user_id;

CREATE TEMP TABLE withdrawal_slot_26oct_s2  AS
SELECT 
  user_id,
  SUM(loyalty_points) AS withdrawal_points,
  COUNT(*) AS num_withdrawal
FROM Withdrawal_Amount_data
WHERE datetime >= '2022-10-26 12:00:00' AND datetime < '2022-10-27 00:00:00'
GROUP BY user_id;


CREATE TEMP TABLE gameplay_slot_26oct_s2  AS
SELECT 
  user_id,
  SUM(loyalty_points) AS game_points,
  SUM("games_played") AS games_played
FROM User_Gameplay_data
WHERE datetime >= '2022-10-26 12:00:00' AND datetime < '2022-10-27 00:00:00'
GROUP BY user_id;


DROP TABLE IF EXISTS bonus_slot_26oct_s2 
CREATE TEMP TABLE bonus_slot_26oct_s2  as
WITH deposits AS (
  SELECT user_id, COUNT(*) AS num_deposit
  FROM Deposit_Amount_Data
WHERE datetime >= '2022-10-26 12:00:00' AND datetime < '2022-10-27 00:00:00'
  GROUP BY user_id
  ORDER BY 2 desc
),
withdrawals AS (
  SELECT user_id, COUNT(*) AS num_withdrawal
  FROM Withdrawal_Amount_data
WHERE datetime >= '2022-10-26 12:00:00' AND datetime < '2022-10-27 00:00:00'
  GROUP BY user_id
  ORDER BY 2 desc
)
SELECT
  COALESCE(d.user_id, w.user_id) AS user_id,
  COALESCE(d.num_deposit, 0) AS num_deposit,
  COALESCE(w.num_withdrawal, 0) AS num_withdrawal,
  0.001 * GREATEST(COALESCE(d.num_deposit, 0) - COALESCE(w.num_withdrawal, 0), 0) AS bonus_points
FROM deposits d
FULL OUTER JOIN withdrawals w ON d.user_id = w.user_id;


SELECT 
  COALESCE(d.user_id, w.user_id, g.user_id, b.user_id) AS user_id,
  COALESCE(d.deposit_points, 0) AS deposit_points,
  COALESCE(w.withdrawal_points, 0) AS withdrawal_points,
  COALESCE(g.game_points, 0) AS game_points,
  COALESCE(b.bonus_points, 0) AS bonus_points,
  (
    COALESCE(d.deposit_points, 0) +
    COALESCE(w.withdrawal_points, 0) +
    COALESCE(g.game_points, 0) +
    COALESCE(b.bonus_points, 0)
  ) AS total_loyalty_points
FROM deposit_slot_26oct_s2  d
FULL OUTER JOIN withdrawal_slot_26oct_s2 w ON d.user_id = w.user_id
FULL OUTER JOIN gameplay_slot_26oct_s2 g ON COALESCE(d.user_id, w.user_id) = g.user_id
FULL OUTER JOIN bonus_slot_26oct_s2 b ON COALESCE(d.user_id, w.user_id, g.user_id) = b.user_id
ORDER BY total_loyalty_points DESC


--2. Calculate overall loyalty points earned and rank players on the basis 
--of loyalty points in the month of October.
--In case of tie, number of games played should be taken as the next criteria for ranking

CREATE TEMP TABLE deposit_points_to_give_ranking AS
SELECT 
  user_id,
  SUM(loyalty_points) AS deposit_points,
  COUNT(*) AS num_deposit
FROM Deposit_Amount_Data
WHERE EXTRACT(MONTH FROM datetime) = 10
GROUP BY user_id;


CREATE TEMP TABLE withdrawal_points_to_give_ranking AS
SELECT 
  user_id,
  SUM(loyalty_points) AS withdrawal_points,
  COUNT(*) AS num_withdrawal
FROM Withdrawal_Amount_data
WHERE EXTRACT(MONTH FROM datetime) = 10
GROUP BY user_id;


CREATE TEMP TABLE gameplay_points_to_give_ranking AS
SELECT 
  user_id,
  SUM(loyalty_points) AS game_points,
  SUM("games_played") AS games_played
FROM User_Gameplay_data
WHERE EXTRACT(MONTH FROM datetime) = 10
GROUP BY user_id;


DROP TABLE IF EXISTS bonus_points_to_give_ranking
CREATE TEMP TABLE  bonus_points_to_give_ranking AS

WITH deposits AS (
  SELECT user_id, COUNT(*) AS num_deposit
  FROM Deposit_Amount_Data
WHERE EXTRACT(MONTH FROM datetime) = 10
  GROUP BY user_id
  ORDER BY 2 desc
),
withdrawals AS (
  SELECT user_id, COUNT(*) AS num_withdrawal
  FROM Withdrawal_Amount_data
WHERE EXTRACT(MONTH FROM datetime) = 10
  GROUP BY user_id
  ORDER BY 2 desc
)
select
  COALESCE(d.user_id, w.user_id) AS user_id,
  COALESCE(d.num_deposit, 0) AS num_deposit,
  COALESCE(w.num_withdrawal, 0) AS num_withdrawal,
  0.001 * GREATEST(COALESCE(d.num_deposit, 0) - COALESCE(w.num_withdrawal, 0), 0) AS bonus_points
FROM deposits d
FULL OUTER JOIN withdrawals w ON d.user_id = w.user_id;


CREATE TEMP TABLE loyalty_points_for_ranking as

SELECT 
  COALESCE(d.user_id, w.user_id, g.user_id, b.user_id) AS user_id,
  COALESCE(d.deposit_points, 0) AS deposit_points,
  COALESCE(w.withdrawal_points, 0) AS withdrawal_points,
  COALESCE(g.game_points, 0) AS game_points,
  COALESCE(b.bonus_points, 0) AS bonus_points,
  (
    COALESCE(d.deposit_points, 0) +
    COALESCE(w.withdrawal_points, 0) +
    COALESCE(g.game_points, 0) +
    COALESCE(b.bonus_points, 0)
  ) AS total_loyalty_points
FROM deposit_points_to_give_ranking d
FULL OUTER JOIN withdrawal_points_to_give_ranking w ON d.user_id = w.user_id
FULL OUTER JOIN gameplay_points_to_give_ranking g ON COALESCE(d.user_id, w.user_id) = g.user_id
FULL OUTER JOIN bonus_points_to_give_ranking b ON COALESCE(d.user_id, w.user_id, g.user_id) = b.user_id
ORDER BY total_loyalty_points DESC

SELECT * FROM loyalty_points_for_ranking

--Ranking the players 
-- i am using game_points to break tie instead of using games_palyed exactly because game_points is directly
--proprtional to games_played as i can also use game_points to break the tie in place of games_payed to
--simplify the query
CREATE TEMP TABLE top_50_players AS
WITH ranking_of_players as(
SELECT *,
DENSE_RANK() over(ORDER BY COALESCE(total_loyalty_points,0) DESC , COALESCE(game_points, 0) DESC) AS Player_ranking
FROM loyalty_points_for_ranking
)
SELECT * FROM ranking_of_players
LIMIT 50

SELECT * FROM top_50_players

-- Distributing bonus proportionally among top 50 players

SELECT 
  user_id,
  total_loyalty_points,
  ROUND(
    (total_loyalty_points / SUM(total_loyalty_points) OVER ()) * 50000,
    2
  ) AS bonus_awarded
FROM top_50_players
ORDER BY bonus_awarded DESC;

--3.What is the average deposit amount?

SELECT 
  AVG(deposit_amount) AS avg_deposit_amount
FROM Deposit_Amount_Data;

--4. What is the average deposit amount per user in a month?
SELECT 
  AVG(user_total_deposit) AS avg_deposit_per_user_a_month
FROM (
  SELECT 
    user_id,
    SUM(deposit_amount) AS user_total_deposit
  FROM Deposit_Amount_Data
  WHERE extract(month from datetime)=10
  GROUP BY user_id
)

--5. What is the average number of games played per user?
SELECT 
  AVG(total_games_per_user) AS avg_games_played_per_user
FROM (
  SELECT 
    user_id,
    SUM(games_played) AS total_games_per_user
  FROM User_Gameplay_data
  GROUP BY user_id
) AS user_game_totals;





