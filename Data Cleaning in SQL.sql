-- Data Cleaning

Select *
From layoffs;

-- 1. Remove duplicates if there are any
-- 2. Standardize the data by correcting spelling mistakes or any other mistake
-- 3. NULL values or blank values
-- 4. Remove any columns or rows

CREATE TABLE layoffs_staging
LIKE layoffs;


Select *
From layoffs_staging;

INSERT layoffs_staging
SELECT * 
FROM layoffs;


-- Trying to identify duplicates

SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, 
country, funds_raised_millions) AS row_num
From layoffs_staging;

-- if the row number has 2 or more then there are duplicates. 

WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, 
country, funds_raised_millions) AS row_num
From layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;
-- this code shows how many rows have duplicates


-- to verify, 
Select *
From layoffs_staging
WHERE company = 'Casper';
 
 -- to remove one of the rows, remember you cant delete a cte so you put it in another table
 
 WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, 
country, funds_raised_millions) AS row_num
From layoffs_staging
)
DELETE  
FROM duplicate_cte
WHERE row_num > 1;
 -- this doesnt work. it is not updatable
 
 
 -- you do this by right clicking on layoffs_staging on the left and copy the create statement from the clipboard
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
   `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

 SELECT *
 FROM layoffs_staging2
 WHERE row_num > 1;
 
 INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, 
country, funds_raised_millions) AS row_num
From layoffs_staging;


 DELETE
 FROM layoffs_staging2
 WHERE row_num > 1;
 
  SELECT *
 FROM layoffs_staging2;
 
 -- the code above didn't work so I am pasting the one I got from Claude. After some edits the codes above worked.
 
 DELETE FROM layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, 
       stage, country, funds_raised_millions) IN (
    
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`,
           stage, country, funds_raised_millions
    FROM (
        SELECT *, 
               ROW_NUMBER() OVER (
                   PARTITION BY company, location, industry, total_laid_off, 
                   percentage_laid_off, `date`, stage, country, funds_raised_millions
               ) AS row_num
        FROM layoffs_staging
    ) sub
    WHERE row_num > 1
);
 -- It later worked when I changed the safe update under preferences under EDIT. You have to restart the application for it to work.
 
  -- Standardizing data. It is finding issues in your data and fixing them.
  
  Select DISTINCT (TRIM(company))
  From layoffs_staging2;
  
 Select company, TRIM(company)
  From layoffs_staging2;
  
  -- to update company format, use this example.
  Update layoffs_staging2
  Set company = TRIM(company);
  
  
   Select DISTINCT industry
  From layoffs_staging2;
  
  Select DISTINCT industry
  From layoffs_staging2
  Order By 1;
  
  -- you need to combine crypto and crypto currency because they are the same thing
  Select *
  From layoffs_staging2
 Where industry Like 'Crypto%';
  
  Update layoffs_staging2
  Set industry = 'Crypto%'
  Where industry Like 'Crypto%';
  
 Select *
  From layoffs_staging2; 
  
  -- do this for all the comn headings.
  
  Select Distinct location
  From layoffs_staging2
  Order By 1;
  
  Select Distinct country
  From layoffs_staging2
  Order By 1;
 -- we have to correct the '.' after United States
 Select *
  From layoffs_staging2
  Where country Like 'United States%'
  Order By 1;
  -- to fix it, use an advanced code
  
  Select Distinct country, Trim(Trailing '.' From country)
  From layoffs_staging2
  Order By 1;
  
  Update layoffs_staging2
  Set country = Trim(Trailing '.' From country)
  Where country Like 'United States%';
  
  Select Distinct country
  From layoffs_staging2
  Order By 1;
  
-- changing date to a time series date column

 Select `date`
  From layoffs_staging2;
  
 Select `date`,
 STR_TO_DATE(`date`, '%m/%d/%Y')
  From layoffs_staging2; 
  
  Update layoffs_staging2
  Set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
  
  -- After this, it will still say text under definition. to fix this,
  
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- fix NULL values
  
   Select *
  From layoffs_staging2
  Where industry IS NULL
  OR industry = ''; 

 Select *
  From layoffs_staging2
  Where company = 'Airbnb'; 
  -- Since Airbnb is a travel company, we fill the blank space with travel. To do that, first change all blanks to NULL
  
  Update layoffs_staging2
  Set industry = NULL
  Where industry = '';
  
  Select Distinct industry
  From layoffs_staging2;
  
  
  Select *
  From layoffs_staging2 t1
  Join layoffs_staging2 t2
  On t1.company = t2.company
  And t1.location = t2.location
Where t1.industry Is NULL 
And t2.industry Is Not NULL;


  Update layoffs_staging2 t1
  Join layoffs_staging2 t2
  On t1.company = t2.company
  Set t1.industry = t2.industry
  Where t1.industry Is NULL 
And t2.industry Is Not NULL; 

-- Now do the same for 'Bally''s Interactive'. 
Select *
  From layoffs_staging2
  Where company Like 'Bally''s Interactive';
  -- In this case there was only one lay off so you can't update it.
  
  Select *
  From layoffs_staging2;
  
  -- -- Removing columns and rows you need to. 
  Select *
  From layoffs_staging2
  Where total_laid_off IS NULL
  And percentage_laid_off IS NULL; 
  
  Delete
  From layoffs_staging2
  Where total_laid_off IS NULL
  And percentage_laid_off IS NULL; 
  
  -- -- remove the column (row_num)
  Alter table layoffs_staging2
  Drop Column row_num;
  
  
  -- -- THE END -- --