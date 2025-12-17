drop table if exists netflix;
Create Table netflix
(
  show_id varchar(6),
  typee   varchar(10),
  title   varchar(150),
  director varchar(220),
  caste   varchar(1000),
  country varchar(150),
  date_added varchar(50),
  release_year int,
  rating varchar(20),
  duration varchar(20),
  listed_in varchar(100),
  description varchar(300)
);
select * from netflix;

select count(*) as total_content from netflix;

select distinct typee from netflix;

-- cnt no. of movies and tv shows we have
select 
 typee,
 count(*) as total_content
from netflix
group by typee;

--2. Find most common rating for movies and TV shows
select typee, rating 
from
( 
 SELECT 
  typee,
 rating,
 count(*),
  rank() over(partition by typee order by count(*)) as ranking
 
 -- max(rating)
 from netflix
 group by 1, 2
 -- order by 1, 3 desc;
) as t1
where ranking = 1;

-- list all the movies in specific year
select * from netflix 
where release_year = 2020 and typee = 'Movie';

-- top 5 countries which has most content on netflix
select country,
count(show_id) as total_content
From netflix
Group by 1

SELECT new_country, total_content
FROM (
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
        COUNT(*) AS total_content
    FROM netflix
    WHERE country IS NOT NULL
    GROUP BY 1
) t
ORDER BY total_content DESC
LIMIT 10;

--longest movie
select * from netflix
where 
   typee = 'Movie'
   AND 
   duration = (select max(duration) from netflix)

-- content released within last 5 years

select *
from netflix
where
     to_date(date_added, 'Month DD, YYYY') >= current_date - Interval '5 years';

--select current_date - Interval '5 years';

-- Find all movies/TV shows by director 'Rajiv Chilaka'
select * from netflix
where director = 'Rajiv Chilaka';

-- In case we have multiple directors of the movie so that should also be counted

select * from netflix
where director like '%Rajiv Chilaka%';

-- ilike is not case sensitive
select * from netflix
where director ilike '%rajiv chilaka%';

--List TV shows with more than 5 seasons



SELECT *
FROM netflix 
WHERE typee = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

--Explaination of split part
select split_part('IIT NIT IIIT',' ',1);
-- conditional
select split_part('1 2 3 4 5',' ',3):: int > 2;

--Count no. of content items in each genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
    COUNT(show_id) as cnt 
    FROM netflix
	group by 1
	order by cnt asc;

--Find each year and the average numbers of content release in India on netflix.
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country ilike '%India%')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--List All Movies that are Documentaries and are released in bw 2020 and 2018
select * from netflix
where listed_in ilike '%Documentaries%'
and release_year in  (2020, 2019, 2018)
and caste is NOT NULL
order by show_id ;

-- Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

-- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
select 
 unnest(string_to_array(caste, ',')) as actor,
 count(*)
from netflix
where country = 'India'
group by actor
order by count(*) desc
limit 10;

-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
select
 category,
 count(*) as content_count
from (
select
      case
	   when description ilike '%kill%' or description ilike '%violence%' then 'BAD'
	   else 'GOOD'
	  end as category
from netflix
) as categorized_content
group by category;

SELECT * 
FROM netflix
WHERE caste LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 15;