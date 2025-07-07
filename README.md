# Loyalty-Analytics & Reward-Distribution-SQL

## Project Overview

**Project Title**: Loyalty-Analytics & Reward-Distribution 
**Database**: `ABC_Gaming_Database`

ABC is a real-money online gaming company providing multiplayer games such as Ludo. An user can register as a player, deposit money in the platform and play games with other players on the platform.
If he/she wins the game then they can withdraw the winning amount while the platform charges a nominal fee for the services.
To retain players on the platform, the company ABC gives loyalty points to their players based on their activity on the platform.
Loyalty points are calculated on the basis of the number of games played, deposits and withdrawal made on the platform by a particular player.
The criteria to convert number of games played, deposits and withdrawal into points is given as below :

![loyalty points disribution](https://github.com/giriaman610/Loyalty-Analytics-Reward-Distribution--SQL/blob/main/Loyal%20points%20distribution.png)

Final Loyalty Point Formula<br>
Loyalty Point = (0.01 * deposit) + (0.005 * Withdrawal amount) + (0.001 * (maximum of (#deposit - #withdrawal) or 0)) + (0.2 * Number of games played)



## Objectives
**This project presents a player loyalty analysis for ABC, a real-money gaming platform.
Using player activity data (deposits, withdrawals, and games), the goal is to calculate
loyalty points, rank users, and propose a bonus distribution method. Additionally, this
project evaluates the fairness of the existing loyalty formula.**

## Project Structure

- **Database Creation**: The project starts by creating a database named `ABC_Gaming_Database`.
- **Table Creation**: Tables are created of different datasets deposit_amount_data,withdrawal_amount_data

```sql
CREATE DATABASE ABC_Gaming_Database;
- Importing User Gameplay Data

DROP TABLE IF EXISTS User_Gameplay_data
CREATE TABLE User_Gameplay_data(
User_ID	integer,
Games_Played integer,
Datetime TIMESTAMP
)

- Importing User Deposit_Amount_Data

DROP TABLE IF EXISTS Deposit_Amount_Data
CREATE TABLE Deposit_Amount_Data(
User_ID	integer,
Datetime TIMESTAMP,
deposit_Amount   integer
)

- Importing User Withdrawal_Amount_data

DROP TABLE IF EXISTS Withdrawal_Amount_data
CREATE TABLE Withdrawal_Amount_data(
User_ID	integer,
Datetime TIMESTAMP,
withdrawal_Amount  integer
)

```

### 3. Data Analysis & Findings
**Part A - Calculating loyalty points**
On each day, there are 2 slots for each of which the loyalty points are to be calculated:
S1 from 12am to 12pm
S2 from 12pm to 12am
Based on the above information and the data provided answer the following questions:

 **1.Now calculating loyality points for each category in repsective table**:
```sql
1.deposit  amount table

ALTER TABLE Deposit_Amount_Data ADD COLUMN loyalty_points NUMERIC;
UPDATE Deposit_Amount_Data
SET loyalty_points = 0.01 * "deposit_amount";

-2.calculating loyalty points withdrawal amount table

ALTER TABLE Withdrawal_Amount_data ADD COLUMN loyalty_points NUMERIC;
UPDATE Withdrawal_Amount_data
SET loyalty_points = 0.005 * "withdrawal_amount";

3.Gameplay data table

ALTER TABLE User_Gameplay_data ADD COLUMN loyalty_points NUMERIC;
UPDATE User_Gameplay_data
SET loyalty_points = 0.2 * "games_played";

```

 **2 a. Calculating total loyalty points for 2nd October Slot S1**:
```sql
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

```
**2 b.Calculating total loyalty points for 16nd October Slot S2**:
```sql
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
```
 
 **2 c.Calculating total loyalty points for 18nd October Slot S1**:
```sql
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
```

**2 d.Calculating total loyalty points for 26nd October Slot S2**:
```sql
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
```

6. **write a query to return the email,firstname,lastname and genre of all rock music listeners written your list ordered alphabetically by email starting with A.**:
```sql
select distinct (customer.email),customer.first_name,customer.last_name,genre.name
from genre
join track on genre.genre_id=track.genre_id
join invoice_line on track.track_id=invoice_line.track_id
join invoice on invoice_line.invoice_id=invoice.invoice_id
join customer  on invoice.customer_id=customer.customer_id
where genre.name='Rock'
order by email;
```

**3.Calculate overall loyalty points earned and rank players on the basis of loyalty points in the month of October.In case of tie,
    number of games played should be taken as the next criteria for ranking**:
```sql
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
```

**4.Ranking the players i am using game_points to break tie instead of using games_palyed exactly because game_points is directly proprtional to games_played
As we can also use game_points to break the tie in place of games_payed to**
```sql
CREATE TEMP TABLE top_50_players AS
WITH ranking_of_players as(
SELECT *,
DENSE_RANK() over(ORDER BY COALESCE(total_loyalty_points,0) DESC , COALESCE(game_points, 0) DESC) AS Player_ranking
FROM loyalty_points_for_ranking
)
SELECT * FROM ranking_of_players
LIMIT 50

SELECT * FROM top_50_players
```

 **5.Distributing bonus proportionally among top 50 players**:
```sql
SELECT 
  user_id,
  total_loyalty_points,
  ROUND(
    (total_loyalty_points / SUM(total_loyalty_points) OVER ()) * 50000,
    2
  ) AS bonus_awarded
FROM top_50_players
ORDER BY bonus_awarded DESC;
```

**6.What is the average deposit amount per transaction**:
```sql
SELECT 
  AVG(deposit_amount) AS avg_deposit_amount
FROM Deposit_Amount_Data;
```

**7.What is the average deposit amount per user in a month**:
```sql
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

```
**8.What is the average number of games played per user**:
```sql
SELECT 
  AVG(total_games_per_user) AS avg_games_played_per_user
FROM (
  SELECT 
    user_id,
    SUM(games_played) AS total_games_per_user
  FROM User_Gameplay_data
  GROUP BY user_id
) AS user_game_totals;

```

## Findings

- **Analyzed user behavior**on a real-money gaming platform to improve loyalty-based engagement and reward distribution**.
- **Created modular SQL pipelines** using temporary tables to compute slot-wise and monthly user-level activity metrics.
- **Identified top 50** loyal users and designed a data-driven ₹50,000 bonus allocation strategy using proportional distribution using SQL.
- **Evaluated fairness** of the existing loyalty formula and recommended enhancements to improve user retention and platform engagement..

## suggestions

- Increase the weight of gameplay Boost( 0.2 × games to 0.5) to reward users who consistently engage.
- Reduce or remove points for withdrawals Since withdrawals reduce user balance, rewarding them (even lightly) may not be.
- Referral-based bonuses Encourage word-of-mouth growth by awarding points for verified referrals.
-  Incorporate streaks or session frequency Award bonus points for consecutive days of login or play to drive retention

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.



