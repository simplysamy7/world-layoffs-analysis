-- World Layoffs Project (2022-2023 May)

-- Data Cleaning
-- 1. Remove duplicates
-- 2. Standadrdize the data
-- 3. Remove nulls and blanks
-- 4. Remove any unncessary columns or rows

-- Creating a duplicate table for staging using CREATE TABLE and LIKE statements to not modify raw data:
CREATE TABLE layoffs_staging
LIKE world_layoffs.layoffs;

-- Adding all the data from layoffs to layoffs_staging table
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Checking if all the data has been added to the staging table
SELECT *
FROM layoffs_staging;



-- STEP 1: CHECKING FOR DUPLICATES 

-- A. Assigning row number to each record. If row number is over 1, then it may be duplicate
SELECT *,
	ROW_NUMBER()OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,
    funds_raised_millions) AS row_num -- Added all column cause sometimes Co. name maybe common but metrics maybe different and thus weong results
FROM layoffs_staging;

-- B. Using CTE, we create a temporary result set to identify cos. which have two records
WITH duplicate_cte AS 
(
	SELECT *,
	ROW_NUMBER()OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,
    funds_raised_millions) AS row_num -- Added all column cause sometimes Co. name maybe common but metrics maybe different and thus weong results
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num>1; -- Only result is company Oyster

-- Cross-checking if Oyster is really duplicate
SELECT *
FROM layoffs_staging
WHERE company="Oyster"; -- NOT duplicate cause name is different


-- STEP 2: STANDARDIZING DATA

-- A. Removing white spaces or trailing spaces from column company
SELECT company, TRIM(company)
FROM layoffs_staging;

-- Replacing column with spaces with trimmed column to table
UPDATE layoffs_staging
SET company=TRIM(company);

SET SQL_SAFE_UPDATES = 0;

-- B. Investigating the industry and country column for anomalies
SELECT DISTINCT industry, country
FROM layoffs_staging
ORDER BY 1; -- we find Crypto, Crypto currency and cryptocureency and double entries under United States and United States.

-- Standaridizng industry values to crypto
UPDATE layoffs_staging
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry FROM layoffs_staging ORDER BY 1;-- checking if changes are reflecting

-- Standardizing country United States
UPDATE layoffs_staging
SET country="United States"
WHERE COUNTRY LIKE "United States%";

SELECT DISTINCT country FROM layoffs_staging ORDER BY 1 DESC;-- checking if changes are reflecting

-- C. converting Date type from string to date type
SELECT `date`,
	STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging;

-- Updating table with correct variable type
UPDATE layoffs_staging
SET `date`=STR_TO_DATE(`date`,'%m/%d/%Y');

-- In schema however the data type remian text, so we have to change variable type in schema as well
ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;


-- STEP 3: REMOVING NULL AND BLANKS

-- A. Inspecting coolumns which have nulls
SELECT *
FROM layoffs_staging; -- Columns having nulls: industry, total_laid_off,percentage_laid_off,funds_raised_millions
					-- Columns having missing values: industry CAN ONLY BE POPULATED
  

SELECT *
FROM layoffs_staging 
WHERE industry IS NULL OR industry=' '; -- Company is Bally's Interactive

/*  Search if this company had multiple layoffs, then it will have more records. If industry is populated for that record
fill up this record with blank with that industry value */

SELECT *
FROM layoffs_staging
WHERE company="Bally's Interactive"; -- Only single record under this company name

--  Using Self join on table compare company records in order to populate missing or nulls
SELECT *
FROM layoffs_staging AS t1 
	JOIN layoffs_staging AS t2 
    ON t1.company=t2.company
WHERE (t1.industry IS NULL or t1.industry=' ')
	AND t2.industry IS NOT NULL; -- no results
    
-- Googling about company to see which industry it belongs to. Google shows ENTERTAINMENT industry
-- Finding similar industry and populating blanks correctly then
SELECT DISTINCT industry
FROM layoffs_staging; -- Best fit industry is consumer

-- Updating industry for Bally's Interactive
UPDATE layoffs_staging
SET industry="Other"
WHERE company="Bally's Interactive";

-- Checking if change is reflecting
SELECT company,location,industry
FROM layoffs_staging
WHERE company="Bally's Interactive"; -- yes, change is reflecting


-- STEP 4 : DELETING NOT REQUIRED ROWS AND COLUMNS
-- Deleting column row_num
ALTER TABLE layoffs_staging
DROP COLUMN row_num;

SELECT * FROM layoffs_staging; -- checking if column is deleted

-- Deleting records which have both total_laid_off and percentage_laid_off as null
DELETE 
FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;















