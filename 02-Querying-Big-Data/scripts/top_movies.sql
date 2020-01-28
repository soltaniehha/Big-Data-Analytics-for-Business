USE movie_rating;  -- switching the database

DROP VIEW IF EXISTS top_movies;

CREATE VIEW top_movies AS
SELECT movie_id, count(movie_id) number_of_ratings, avg(rating) avg_rating
FROM ratings
GROUP BY movie_id
ORDER BY number_of_ratings DESC;

SELECT m.movie_title title, t.number_of_ratings vote_count, round(t.avg_rating,2) rating
FROM top_movies t
LEFT JOIN movies m
ON t.movie_id = m.movie_id;
