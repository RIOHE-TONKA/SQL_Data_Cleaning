-- Data cleaning

-- 1. Remove duplicates
-- 2. Standadize data, check if any issues with data, spelling eg. to create a common model 
-- 3. Null or black values
-- 4. Elimate unnecesary. columns

SELECT * FROM layoffs;

SELECT COUNT(*)
FROM layoffs;


-- 1. Find duplicates----
WITH duplicates AS(

SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS dups
FROM layoffs
) SELECT * FROM duplicates WHERE dups > 1;

-- Create mirror table to later eliminate dups
CREATE TABLE stage_layoffs
WITH duplicates AS(

SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS dups
FROM layoffs
) SELECT * FROM duplicates;

-- View new mirror table
SELECT * FROM stage_layoffs;

-- Eliminate duplicates
DELETE FROM stage_layoffs
WHERE dups > 1;

-- View table without dups
SELECT * FROM stage_layoffs;

-- Create another mirror table for future operations
CREATE TABLE stage_layoffs2
LIKE stage_layoffs;

INSERT INTO stage_layoffs2
SELECT * FROM stage_layoffs;

SELECT * FROM stage_layoffs2;

-- 2.Standardizing 
-- UPDATE existing column
UPDATE stage_layoffs2
SET company = TRIM(company),
	location = TRIM(location);
    
-- This is just a test to see the before and after in the industry column
SELECT DISTINCT industry, CASE 
        WHEN industry LIKE 'Crypto%' THEN 'Crypto'
        -- ELSE industry 
    END AS updated_industry
FROM stage_layoffs2
WHERE industry LIKE "Crypto%";

SELECT industry
FROM stage_layoffs2
WHERE industry LIKE "Crypto%";

-- Finally. set new industry values to anything stating like Crypto
UPDATE stage_layoffs2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";


-- View update
SELECT industry
FROM stage_layoffs2
WHERE industry LIKE "Crypto%";

-- Viewing corrections on country column
SELECT DISTINCT country, CASE 
							WHEN country LIKE 'United States%' THEN "United States"
                            ELSE country
						 END AS updated_country
FROM stage_layoffs2
WHERE country LIKE "United States%"
ORDER BY 1;

-- Trailing does remove the specified character from the trim
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM stage_layoffs2
WHERE country LIKE "United States%";

UPDATE stage_layoffs2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "United States%";

-- Updating country
SELECT country
FROM stage_layoffs2
WHERE country LIKE "United States%";

-- Testing new date format
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') upd_date
FROM stage_layoffs2
ORDER BY upd_date DESC;

-- Updating date format
UPDATE stage_layoffs2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT * FROM stage_layoffs2;

DESC stage_layoffs2;

-- Modify column datatype in table to new datatype
ALTER TABLE stage_layoffs2
MODIFY COLUMN `date` date;

SELECT * FROM stage_layoffs2;

-- Inspecting null values
SELECT *
FROM stage_layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- In case wanna get rid of null in specified columnns
DELETE FROM stage_layoff3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT company, industry
FROM stage_layoffs2
WHERE company = "Airbnb";

SELECT *
FROM stage_layoffs2
WHERE industry IS NULL;

CREATE TABLE stage_layoffs3
SELECT * FROM stage_layoffs2;

SELECT t1.industry, t2.industry
FROM stage_layoffs3 t1
JOIN stage_layoffs3 t2
ON t1.company = t2.company
AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Updating new populated table
UPDATE stage_layoffs3 t1
JOIN stage_layoffs3 t2
ON t1.company = t2.company
AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * FROM stage_layoffs3
WHERE industry IS NULL;

SELECT * FROM stage_layoffs3;

-- Create new table to eliminate total_laid_off and percentage_laid_off
CREATE TABLE stage_layoffs4
SELECT * FROM stage_layoffs3;

-- Inspecting null values in speciifed columns
SELECT * FROM stage_layoffs4
WHERE total_laid_off IS NULL AND 
		percentage_laid_off IS NULL;

-- Delete columns
DELETE FROM stage_layoffs4
WHERE total_laid_off IS NULL AND 
		percentage_laid_off IS NULL;

SELECT * FROM stage_layoffs4;

ALTER TABLE stage_layoffs4
DROP COLUMN dups;













