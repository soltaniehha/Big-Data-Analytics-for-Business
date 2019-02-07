-- BigQuery
SELECT m.title, round(t.avg_rating,2) rating
FROM `is843-demo.movie_rating_18.movies` m
LEFT JOIN
(
  SELECT movieid, avg(rating) avg_rating
  FROM `is843-demo.movie_rating_18.ratings`
  GROUP BY movieid
) t
ON t.movieid = m.movieid
ORDER BY m.title DESC;

-- Hive
USE movie_rating_18;

SELECT m.title, round(t.avg_rating,2) rating
FROM movies m
LEFT JOIN
(
  SELECT movieid, avg(rating) avg_rating
  FROM ratings
  GROUP BY movieid
) t
ON t.movieid = m.movieid
ORDER BY m.title DESC;
