DROP TABLE IF EXISTS players;

CREATE EXTERNAL TABLE players (
  player STRING,
  height INT,
  weight INT,
  collage STRING,
  born INT,
  birth_city STRING,
  birth_state STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED by ','
TBLPROPERTIES ("skip.header.line.count"="1");

LOAD DATA INPATH '/user/maria_dev/NBA/Players.csv' OVERWRITE INTO TABLE players;
