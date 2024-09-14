--Netflix Project
CREATE TABLE netflix
(
 show_id VARCHAR(6),	
 type VARCHAR(10),
 title VARCHAR(150),	
 director VARCHAR(208),	
 casts VARCHAR(1000),	
 country VARCHAR(150),	
 date_added	VARCHAR(50),
 release_year INT,
 rating VARCHAR(10),
 duration VARCHAR(15),	
 listed_in VARCHAR(100),
 description VARCHAR(250)
);
SELECT * FROM netflix;
SELECT COUNT(*) as total_content FROM netflix;

--15 problems with solution

-- 1. count the number of movies vs tv shows 

SELECT type, count(*) as total_content
FROM netflix
GROUP BY type;

-- 2. find the most common rating for tv shows and movie

SELECT 
type,
rating
FROM
(SELECT 
type,
rating,
count(*),
RANK() OVER(partition by type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1,2
) as t1
WHERE ranking=1;

-- 3. list all the movies released in a specific year i.e 2020

SELECT * FROM netflix
WHERE 
  type='Movie'
  and
  release_year= 2020;

  -- 4. find the top 5 countries with most content on netflix

  SELECT 
  	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_content
  FROM netflix
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 5;

  -- 5. Identify the longest movie

  SELECT * FROM netflix 
  where
    type='Movie'
	and 
	duration=(SELECT max(duration) FROM netflix);

-- 6. find content added in last 5 years

SELECT * FROM
netflix
WHERE
To_date(date_added,'month,DD,YYYY')>=CURRENT_DATE-INTERVAL '5 YEARS';

-- 7. Find all the movies/tv shows by director 'Rajiv Chilaka'

SELECT * FROM netflix
WHERE 
director Ilike '%Rajiv Chilaka%';

-- 8. List all tv shows with more than 5 seasons

SELECT * FROM netflix
WHERE
type='TV Show'
and
SPLIT_PART(duration,' ',1)::numeric > 5

-- 9. count the number of items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

-- 10. find each year and avg number of content released in India on netflix , return top  year with highest avg content release

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*),
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India') ::numeric * 100 as avg_content_per_year
FROM netflix
WHERE country= 'India'
GROUP BY 1

-- 11. list all the movies that are documentries

SELECT * FROM netflix 
WHERE 
listed_in ilike '%documentaries%'


-- 12. Find all content without director

SELECT * FROM netflix 
WHERE director IS NULL

-- 13. find how many movies actor 'salman khan' appeared in last 10years

SELECT * FROM netflix 
WHERE 
casts ilike '%Salman Khan%'
AND 
release_year > EXTRACT (YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15. Categorize the content based on the presence of keywords 'kill' & 'violence' in the description field. label content containing these keywords as 'bad' and rest as 'good'. count how many items fall into each category.

WITH 
new_table as 
(
SELECT 
*,
CASE
WHEN
	description ilike '%kill%' or
	description ilike '%violence%' THEN 'Bad_content'
	ELSE 'good_content'
END category
FROM netflix
)
SELECT 
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1