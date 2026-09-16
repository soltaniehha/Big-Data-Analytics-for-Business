CREATE DATABASE IF NOT EXISTS movie_rating;

USE movie_rating;  -- switching to movie_rating DB

DROP TABLE IF EXISTS ratings;

CREATE TABLE ratings (
  user_id INT,
  movie_id INT,
  rating INT,
  rating_timestamp INT)
ROW FORMAT DELIMITED  -- contains one row per line
FIELDS TERMINATED by '\t'
TBLPROPERTIES ("skip.header.line.count"="1");  -- skip the first line which is the header

LOAD DATA INPATH '/user/maria_dev/movies/ratings.csv' OVERWRITE INTO TABLE ratings;
