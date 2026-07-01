-- Exploratory Data Analysis

Select *
From layoffs_staging2;


Select MAX(total_laid_off), MAX(percentage_laid_off)
From layoffs_staging2;

Select *
From layoffs_staging2
Where percentage_laid_off = 1;


Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by total_laid_off Desc;

Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by funds_raised_millions Desc;

Select company, Sum(total_laid_off)
From layoffs_staging2
Group by company;

-- check what company let the most people go (how many people were laid off by company)
Select company, Sum(total_laid_off)
From layoffs_staging2
Group by company
Order by 2 Desc;

-- to check minimum and maximum date
Select Min(`date`), Max(`date`)
From layoffs_staging2;

-- Check industry had the most layoffs
Select industry, Sum(total_laid_off)
From layoffs_staging2
Group by industry
Order by 2 Desc;

-- country with most laid off
Select country, Sum(total_laid_off)
From layoffs_staging2
Group by country
Order by 2 Desc;

-- date of most laid off
Select `date`, Sum(total_laid_off)
From layoffs_staging2
Group by `date`
Order by 1 Desc;

-- check by year
Select Year(`date`), Sum(total_laid_off)
From layoffs_staging2
Group by Year(`date`)
Order by 1 Desc;

-- check by stage
Select stage, Sum(total_laid_off)
From layoffs_staging2
Group by stage
Order by 2 Desc;

-- check progression of layoffs
Select substring(`date`,6,2) As `Month`, Sum(total_laid_off)
From layoffs_staging2
Group by `Month` ; 

-- -- Rolling total by month
Select substring(`date`,6,2) As `Month`, Sum(total_laid_off)
From layoffs_staging2
Group by `Month` ; 

-- a better way  to check layoff by month would be 
Select substring(`date`,1,7) As `Month`, Sum(total_laid_off)
From layoffs_staging2
Where substring(`date`,1,7) Is Not NULL
Group by `Month`
Order by 1 Asc ; 

-- to do the rolling sum, showing each month and the rolling sum
With Rolling_total As
(
Select substring(`date`,1,7) As `Month`, Sum(total_laid_off) As total_off
From layoffs_staging2
Where substring(`date`,1,7) Is Not NULL
Group by `Month`
Order by 1 Asc 
)
Select  `Month`, total_off,
Sum(total_off) Over(Order by `Month`) As rolling_total
From Rolling_Total
;

-- rolling sum by company
Select company, Sum(total_laid_off)
From layoffs_staging2
Group by company
Order by 2 Desc;

Select company, Year(`date`), Sum(total_laid_off)
From layoffs_staging2
Group by company, Year(`date`)
Order by 3 Desc;

With Company_Year As
(
Select company, Year(`date`), Sum(total_laid_off)
From layoffs_staging2
Group by company, Year(`date`)
Order by 3 Desc
)
Select  *
From Company_Year;

-- this one looks much better. We want to see who laid off the most people per year.
With Company_Year (company, years, total_laid_off) As
(
Select company, Year(`date`), Sum(total_laid_off)
From layoffs_staging2
Group by company, Year(`date`)
)
Select *, Dense_rank() Over (Partition by years Order by total_laid_off DESC) As 'Rank'
From Company_Year;

-- to take out the NULLs,
With Company_Year (company, years, total_laid_off) As
(
Select company, Year(`date`), Sum(total_laid_off)
From layoffs_staging2
Group by company, Year(`date`)
)
Select *, Dense_rank() Over (Partition by years Order by total_laid_off DESC) As Ranking
From Company_Year
Where years is not NULL
Order by Ranking Asc
;


-- Filter for top five companies per year
With Company_Year (company, years, total_laid_off) As
(
Select company, Year(`date`), Sum(total_laid_off)
From layoffs_staging2
Group by company, Year(`date`)
), Comapny_Year_Rank As
(
Select *, Dense_rank() Over (Partition by years Order by total_laid_off DESC) As Ranking
From Company_Year
Where years is not NULL)
Select *
From Comapny_Year_Rank
Where Ranking <= 5;
-- -- you can change it per industry, location, stage etc. Try making new ones