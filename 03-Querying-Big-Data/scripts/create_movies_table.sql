CREATE DATABASE IF NOT EXISTS movie_rating;

USE movie_rating;  -- switching to movie_rating DB

DROP TABLE IF EXISTS movies;

CREATE TABLE movies (
  movie_id INT,
  movie_title STRING,
  release_date STRING,
  video_release_date STRING,
  imdb_url STRING,
  unknown INT,
  action INT,
  adventure INT,
  animation INT,
  childrens INT,
  comedy INT,
  crime INT,
  documentary INT,
  drama INT,
  fantasy INT,
  film_noir INT,
  horror INT,
  musical INT,
  mystery INT,
  romance INT)
COMMENT 'List of movies with their attributes'
ROW FORMAT DELIMITED  -- contains one row per line
FIELDS TERMINATED by '|'
TBLPROPERTIES ("skip.header.line.count"="1");  -- skip the first line which is the header

LOAD DATA INPATH '/user/maria_dev/movies/movies.csv' OVERWRITE INTO TABLE movies;
