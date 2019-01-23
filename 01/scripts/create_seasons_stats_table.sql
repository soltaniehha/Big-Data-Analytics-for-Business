DROP TABLE IF EXISTS seasons_stats;

CREATE EXTERNAL TABLE seasons_stats (
  year INT,
  player STRING,
  position STRING,
  age INT,
  team STRING,
  games INT,
  minutes_played INT,
  field_goals INT,
  field_goal_attempts INT,
  goals_3p INT,
  goals_3p_attempt INT,
  goals_2p INT,
  goals_2p_attempt INT,
  ft INT,
  fta INT,
  points INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED by ','
TBLPROPERTIES ("skip.header.line.count"="1");

LOAD DATA INPATH '/user/maria_dev/NBA/Seasons_Stats.csv' OVERWRITE INTO TABLE seasons_stats;
