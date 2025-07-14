USE imdb;


-- Q1. Find the total number of rows in each table of the schema?

		SELECT COUNT(*) as Total_Rows FROM director_mapping;
		SELECT COUNT(*) as Total_Rows FROM genre;
		SELECT COUNT(*) as Total_Rows FROM movie;
		SELECT COUNT(*) as Total_Rows FROM names;
		SELECT COUNT(*) as Total_Rows FROM Ratings;
		SELECT COUNT(*) as Total_Rows FROM role_mapping;


-- Q2. Which columns in the movie table have null values?

		SELECT 
		(SELECT count(*) FROM movie WHERE id is NULL) as id,
		(SELECT count(*) FROM movie WHERE title is NULL) as title,
		(SELECT count(*) FROM movie WHERE year is NULL) as year,
		(SELECT count(*) FROM movie WHERE date_published is NULL) as date_published,
		(SELECT count(*) FROM movie WHERE duration is NULL) as duration,
		(SELECT count(*) FROM movie WHERE country is NULL) as country,
		(SELECT count(*) FROM movie WHERE worlwide_gross_income is NULL) as worlwide_gross_income,
		(SELECT count(*) FROM movie WHERE languages is NULL) as languages,
		(SELECT count(*) FROM movie WHERE production_company is NULL) as production_company
		;


-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

		select year, count(distinct title) as MovieCount from movie
		group by year;

		select year,month(date_published) as Month, count(distinct title) as MovieCount from movie
		group by year,month(date_published)
		order by year,month(date_published);
 
 
-- Q4. How many movies were produced in the USA or India in the year 2019??

		SELECT Count(DISTINCT id) AS number_of_movies
		FROM movie 
		WHERE (upper(country) LIKE '%INDIA' OR upper(country) LIKE '%USA' ) AND year = 2019;


-- Q5. Find the unique list of the genres present in the data set?

		SELECT DISTINCT genre FROM genre;
        

-- Q6.Which genre had the highest number of movies produced overall?

		SELECT genre, Count(distinct m.id) AS MovieCount
		FROM movie 	AS m
		left JOIN genre AS g on  g.movie_id = m.id
		GROUP BY genre
		ORDER BY MovieCount DESC 
        limit 1;


-- Q7. How many movies belong to only one genre?

		SELECT Count(movie_id) movie_count
		FROM (SELECT movie_id, Count(genre) genre_count
				FROM genre
				GROUP BY movie_id
				ORDER BY genre_count DESC) genre_counts
		WHERE genre_count = 1;
        

-- Q8.What is the average duration of movies in each genre? 

		select genre, avg(duration) as AverageDuration from movie
		left join  genre on movie_id = id
		group by genre;


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

		with movie_rank as 
		(SELECT *, RANK() OVER (ORDER BY MovieCount desc) as GenreRank FROM 
		(
		select genre,count(distinct movie_id) as MovieCount from movie
		left join  genre on movie_id = id
		group by genre
		) A)

		select * from movie_rank where genre = 'Thriller';


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?

		SELECT
			Min(avg_rating) AS min_avg_rating,
			Max(avg_rating) AS max_avg_rating,
			min(total_votes) AS min_total_votes,
			max(total_votes) AS max_total_votes,
			min(median_rating) AS min_midian_rating,
			max(median_rating) AS max_median_rating
		FROM ratings;


-- Q11. Which are the top 10 movies based on average rating?
			
		select title, avg_rating ,
		rank() over (order by avg_rating desc) as movie_rank
		from movie
		left join ratings on movie_id = id
		limit 10;


-- Q12. Summarise the ratings table based on the movie counts by median ratings.

		SELECT 
		median_rating, COUNT(movie_id) as movie_count
		FROM ratings
		GROUP BY median_rating
		ORDER BY movie_count DESC;


-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

		select * from
		(
		select production_company, count(distinct id) as Movie_count,
		rank() over (order by count(distinct id) desc) as prod_company_rank
		from movie
		left join ratings on movie_id = id
		where avg_rating > 8 and production_company is not null
		group by production_company
		)A where prod_company_rank = 1;


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

		select genre, count(distinct m.id) as Movie_count from movie m
		left join genre g on g.movie_id = m.id
		left join ratings r on r.movie_id = m.id
		where country = 'USA'
		and date_published >= '2017-03-01' and date_published < '2017-04-01'
		and total_votes > 1000
		group by genre
		order by Movie_count desc;


-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

		select title, avg_rating, genre from movie m
		left join genre g on g.movie_id = m.id
		left join ratings r on r.movie_id = m.id
		where title like 'The%'
		and avg_rating > 8
		ORDER BY avg_rating DESC;


-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

		select count(distinct m.id) as Movie_count from movie m
		left join genre g on g.movie_id = m.id
		left join ratings r on r.movie_id = m.id
		where date_published >= '2018-04-01' and date_published <= '2019-04-01'
		and median_rating = 8;


-- Q17. Do German movies get more votes than Italian movies? 

		SELECT country, sum(total_votes) as total_votes
		FROM movie as Movies
		INNER JOIN ratings AS RATINGS
		ON Movies.id=RATINGS.movie_id
		WHERE lower(country) = 'germany' or lower(country) = 'italy'
		Group By country;


-- Q18. Which columns in the names table have null values??

		SELECT sum(CASE WHEN name is null then 1 ELSE 0 END) as name_null,
		sum(CASE WHEN height is null then 1 ELSE 0 END) as height_null,
		sum(CASE when date_of_birth is null then 1 ELSE 0 END) as date_of_birth_null,
		sum(case when known_for_movies is null then 1 ELSE 0 end) as known_for_movies_null
		FROM names;


-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

		WITH top_3_genres
		AS (SELECT genre, count(mov.id) AS movie_count,
		Rank() OVER(ORDER BY Count(mov.id) DESC) AS genre_rank
		FROM movie as mov
		INNER JOIN genre AS gen on gen.movie_id = mov.id
		inner join ratings AS rat on rat.movie_id = mov.id
		where avg_rating > 8
		GROUP BY genre limit 3)

		SELECT nam.NAME as director_name, count(dm.movie_id) as movie_count
		FROM director_mapping as dm
		inner join genre as gen using (movie_id)
		inner join names as nam on nam.id = dm.name_id
		inner join top_3_genres using (genre)
		inner join ratings using (movie_id)
		WHERE avg_rating >8
		GROUP BY name
		ORDER BY movie_count DESC limit 3;


-- Q20. Who are the top two actors whose movies have a median rating >= 8?

		select Actor_Name, movie_count from
		(select n.name as Actor_Name, count(distinct rm.movie_id) as movie_count,
		rank() over (order by count(distinct rm.movie_id) desc) as movie_rank
		from role_mapping rm
		inner join ratings r on rm.movie_id = r.movie_id
		inner join names n on n.id = rm.name_id
		where category = 'actor'
		and median_rating >= 8
		group by n.name
		) A
		where movie_rank <=2;




-- Q21. Which are the top three production houses based on the number of votes received by their movies?

		select production_company, sum(total_votes) as vote_count,
		rank() over (order by sum(total_votes) desc) as prod_comp_rank
		from movie
		left join ratings on movie_id = id
		group by production_company
		limit 3;



-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?

		WITH actor_summary as 
		(select n.name AS actor_name, sum(total_votes) AS total_votes,
		 count(R.movie_id) as movie_count,
		Round(Sum(avg_rating * total_votes) / sum(total_votes), 2) as actor_avg_rating
		from movie as m
		INNER JOIN ratings as r on m.id = r.movie_id
		INNER JOIN role_mapping AS rm on m.id = rm.movie_id
		INNER JOIN names as n on rm.name_id = n.id
		WHERE Upper(category) ='ACTOR' 
		AND Upper(country) =  'INDIA'
		GROUP BY name
		HAVING movie_count>=5)
        
		SELECT *, rank() OVER(ORDER BY actor_avg_rating DESC) AS actor_rank
		FROM actor_summary
		LIMIT 1;


-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 

		WITH actress_summary 
		as(SELECT n.name AS actress_name, sum(total_votes) as total_votes, Count(r.movie_id) AS movie_count,
		Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
		FROM movie as m
		INNER JOIN ratings as r ON m.id=r.movie_id
		INNER JOIN role_mapping as rm ON m.id = rm.movie_id
		INNER JOIN names as n ON rm.name_id = n.id
		WHERE Upper(category) = 'ACTRESS' 
		AND Upper(country) = "INDIA" 
		AND Upper(languages) LIKE '%HINDI%'
		GROUP BY name
		HAVING movie_count>=3)
		SELECT *, Rank() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
		FROM actress_summary LIMIT 5;


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

		SELECT distinct title, avg_rating,
		CASE WHEN avg_rating > 8 THEN "Superhit movies"
		WHEN avg_rating between 7 and 8 THEN "Hit movies"
		WHEN avg_rating between 5 and 7 THEN "One-time-watch movies"
		WHEN avg_rating < 5 THEN "Flop movies"
		END AS avg_rating_category
		from movie as mov inner join ratings as Ratings
		on mov.id = Ratings.movie_id
		inner join genre as gen on gen.movie_id = mov.id
		where upper(genre) = 'THRILLER';

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 

		SELECT genre, ROUND(avg(duration),2) AS avg_duration,
		Sum(round(avg(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
		Round(avg(avg(duration)) OVER(ORDER BY genre ROWS 10 PRECEDING),2) AS moving_avg_duration
		FROM movie AS m 
		INNER JOIN genre AS g ON m.id= g.movie_id
		GROUP BY genre ORDER BY genre;




-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 

		WITH top_3_genres as
		(select genre, Count(m.id) AS movie_count ,
		Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
		FROM movie AS m
		INNER JOIN genre AS g ON g.movie_id = m.id
		INNER JOIN ratings AS r ON r.movie_id = m.id
		GROUP BY genre 
		 limit 3 
		),
		worlwide_gross_income as
		(SELECT year, title AS movie_name,genre,
		CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worlwide_gross_income,
		DENSE_RANK() OVER(partition BY year ORDER BY CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10))  DESC ) AS movie_rank
		FROM movie AS m 
		INNER JOIN genre AS g ON m.id = g.movie_id
		WHERE genre IN
		( SELECT genre FROM top_3_genres)
		)
        
        select * FROM worlwide_gross_income
        WHERE movie_rank <=5
        order by year;


-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?

		WITH production_company_detail
		as (SELECT production_company, Count(*) AS movie_count
		FROM movie AS mov
		INNER JOIN ratings as rat on rat.movie_id = mov.id
		WHERE median_rating >= 8 and production_company IS NOT NULL
		AND Position(',' IN languages) > 0
		GROUP BY production_company
		ORDER BY movie_count DESC)
		SELECT *, Rank() over( ORDER BY movie_count DESC) AS prod_comp_rank
		FROM production_company_detail LIMIT 2;


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

		WITH actress_summary 
		as( SELECT n.name as actress_name, sum(total_votes) as total_votes,
		Count(r.movie_id) as movie_count, Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
		FROM movie as m
		INNER JOIN ratings as r ON m.id=r.movie_id
		INNER JOIN role_mapping as rm ON m.id = rm.movie_id
		INNER JOIN names as n ON rm.name_id = n.id
		INNER JOIN GENRE as g ON g.movie_id = m.id
		WHERE lower(category) = 'actress' AND avg_rating>8 AND lower(genre) = "drama"
		GROUP BY name )

		SELECT *, dense_rank() OVER(ORDER BY movie_count DESC) AS actress_rank
		FROM actress_summary LIMIT 3;


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations*/

		WITH next_date 
		as( SELECT d.name_id, name, d.movie_id, duration, r.avg_rating, total_votes, m.date_published,
		Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) as next_date
		FROM director_mapping as d
		INNER JOIN names as n on n.id = d.name_id
		INNER JOIN movie as m on m.id = d.movie_id
		INNER JOIN ratings as r on r.movie_id = m.id ), 

		top_director_summary as
		( SELECT *, Datediff(next_date, date_published) as date_difference
		FROM next_date )

		SELECT   
		name_id as director_id,
		name as director_name,
		Count(movie_id) as number_of_movies,
		Round(avg(date_difference),2) as avg_inter_movie_days,
		Round(Avg(avg_rating),2) as avg_rating,
		Sum(total_votes) as total_votes,
		Min(avg_rating) as min_rating,
		Max(avg_rating) as max_rating,
		Sum(duration) as total_duration
		FROM top_director_summary
		GROUP BY director_id
		ORDER BY Count(distinct movie_id) DESC 
		LIMIT 9;


