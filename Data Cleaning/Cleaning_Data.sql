-- Cleaning data

-- Remove dups
-- Standardise the data
-- Look for Null or blank values
-- Remove unnecesary raws/columns

SELECT count(*) FROM layoffs;

SELECT * 
FROM layoffs;

CREATE TABLE layoffs_stage
SELECT *
FROM layoffs;

SELECT * 
FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions) AS row_num
				FROM layoffs_stage) Subquery
				WHERE row_num > 1;
             

WITH duplicates AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_stage
)SELECT * FROM duplicates WHERE row_num > 1;


-- One way to find dups with subqueries
SELECT * 
FROM (SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,stage, country, funds_raised_millions) AS dups
FROM layoffs_stage ) AS Subquery
WHERE dups >1;

-- Another way to find dups with CTEs
WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,stage, country, funds_raised_millions) AS dups
FROM layoffs_stage
)
SELECT * FROM duplicate_cte
WHERE dups > 1;

-- Create a table to mirror and delete dups
CREATE TABLE layoffs_stage2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,stage, country, funds_raised_millions) AS dups
FROM layoffs_stage;

-- Delete duplicates
DELETE FROM layoffs_stage2 
WHERE dups > 1;

-- Standardization
SELECT * FROM layoffs_stage2;

-- Change column from dec to int
ALTER TABLE layoffs_stage2
MODIFY COLUMN funds_raised_millions INT;

ALTER TABLE layoffs_stage2  
MODIFY COLUMN percentage_laid_off DOUBLE;

-- Fix industry
SELECT industry
FROM layoffs_stage2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_stage2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT industry, 
ROW_NUMBER() OVER(PARTITION BY industry) 
FROM layoffs_stage2;

SELECT COUNT(country)
FROM layoffs_stage2
ORDER BY 1;
-- WHERE country LIKE 'United States%';

SELECT DISTINCT(country), REPLACE(country,'.',"")
FROM layoffs_stage2
WHERE country LIKE 'United States%';

UPDATE layoffs_stage2
SET country = REPLACE(country,'.',"")
WHERE country LIKE 'United States%';

SELECT `date`
FROM layoffs_stage2;

UPDATE layoffs_stage2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT * 
FROM layoffs_stage2
WHERE location LIKE "Washing%";

ALTER TABLE layoffs_stage2
MODIFY COLUMN `date` DATE;

DESC layoffs_stage2;

-- Fix Null or empty values

SELECT *
FROM layoffs_stage2;

SELECT *
FROM layoffs_stage2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_stage2
WHERE industry IS NULL OR industry = "";

SELECT * 
FROM layoffs_stage2
WHERE company = 'Airbnb';

SELECT t1.industry T1, t2.industry T2
FROM layoffs_stage2 t1
JOIN layoffs_stage2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

CREATE TABLE layoffs_stage3
SELECT * 
FROM layoffs_stage2;

UPDATE layoffs_stage3 t1
JOIN layoffs_stage3 t2
ON t1.company = t2.company
AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT t1.industry T1, t2.industry T2
FROM layoffs_stage3 t1
JOIN layoffs_stage3 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NOT NULL)
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_stage3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_stage3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_stage3;

ALTER TABLE layoffs_stage3
DROP COLUMN dups;



