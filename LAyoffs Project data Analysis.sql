-- EXPLORATORY DATA ANALYSIS

-- 1. What are the dates for the dataset?
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging; -- 6.12.2022 to 6.3.2022

-- 2. What was the highest no. of people laid off?
SELECT company,`date`,MAX(total_laid_off)
FROM layoffs_staging
GROUP BY 1,2
ORDER BY 3 DESC; -- Company name is google

-- 3. Which companies recorded full layoff (100%) of their workforce?
SELECT *
FROM layoffs_staging
WHERE percentage_laid_off=1 -- because 1 means 100%
ORDER BY funds_raised_millions DESC; -- To see how big the companies were

-- 4. Top 10 companies with maximum layoffs over the years
SELECT company,SUM(total_laid_off) As total_employees_fired
FROM layoffs_staging
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 5. Which industries were  worst hit?
SELECT industry,SUM(total_laid_off) As total_employees_fired
FROM layoffs_staging
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10; 

-- 6. Which countries were worst hit?
SELECT country,SUM(total_laid_off) As total_employees_fired
FROM layoffs_staging
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10; -- US was worst hit

-- 7. Which year and month was worst hit?
SELECT YEAR(`date`), MONTH(`date`), SUM(total_laid_off) As total_employees_fired
FROM layoffs_staging
GROUP BY 1,2
ORDER BY 3 DESC; -- December '22 to March '23 saw the worst layoffs

-- 8. Stage and position of these companies who were worst hit?
SELECT stage,SUM(total_laid_off) As total_employees_fired
FROM layoffs_staging
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10; -- Post IPO cos. naturally

-- 9. Calculate rolling total layoffs month-wise
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY 1
ORDER BY 1;

WITH rolling_total_table AS -- using CTE
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY 1
ORDER BY 1
)
SELECT `Month`, total_laid_off,
	SUM(total_laid_off) OVER(ORDER BY `Month`) AS rolling_total
FROM rolling_total_table;


-- 10. Rank cos. on the basis of lay-offs

-- Using CTE:
WITH Company_Year_table AS
(
SELECT company,YEAR(`date`) AS `year`, SUM(total_laid_off) AS total_employees_fired
FROM layoffs_staging
GROUP BY 1,2
)
SELECT company,`year`,total_employees_fired,
	DENSE_RANK()OVER(PARTITION BY `year` ORDER BY total_employees_fired DESC) AS ranks
FROM Company_Year_table
WHERE total_employees_fired IS NOT NULL;




