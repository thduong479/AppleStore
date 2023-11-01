--EXPLORATORY DATA ANALYSIS 

SELECT * FROM AppleStore

SELECT COUNT (DISTINCT id) AS UniqueAppIDs
FROM AppleStore

--Checking for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS NULL OR user_rating IS NULL or prime_genre IS NULL 

--Find out the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--Get an overview of the apps' rating

SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore

--Get the distribution of app prices

SELECT (price / 2) *2 AS PriceBinStart,
       ((price / 2) *2) +2 AS PriceBinEnd,
       COUNT(*) AS NumApps
FROM AppleStore
GROUP BY (price / 2) *2 
ORDER BY (price / 2) *2 

--DATA ANALYSIS--

--Determine whether paid apps have higher ratings than free apps

SELECT CASE 
            WHEN price > 0 then 'Paid'
            ELSE 'Free'
       END AS App_Type,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY CASE 
            WHEN price > 0 then 'Paid'
            ELSE 'Free'
       END

--Check if apps with more supported languages have higher ratings

SELECT CASE 
            WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
       END AS language_bucketl,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY CASE
            WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
         END
ORDER BY Avg_Rating

--Check genres with low ratings

SELECT TOP 10 prime_genre, 
       AVG(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC

--Check if there is correlation between the lenghth of the app description

SELECT CASE 
           WHEN LEN(D.app_desc) <500 THEN 'Short'
           WHEN LEN(D.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
           ELSE 'Long'
       END AS description_length_bucket,
       avg(A.user_rating) AS Average_Rating
FROM AppleStore A JOIN appleStore_description D ON A.id = D.id 
GROUP BY CASE WHEN LEN(D.app_desc) <500 THEN 'Short'
              WHEN LEN(D.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
              ELSE 'Long'
         END
ORDER BY Average_Rating DESC

--Check the top-rated apps for each genre

SELECT prime_genre,
       track_name,
       user_rating
FROM (
        SELECT 
            prime_genre,
            track_name,
            user_rating,
            RANK() OVER (PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS Rank
        FROM AppleStore
) AS Subquery
WHERE
Subquery.Rank = 1;
       