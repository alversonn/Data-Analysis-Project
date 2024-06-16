-- Exploratory Data Analysis

SELECT *
FROM phk_copyy2;

SELECT *
FROM phk_copyy2
ORDER BY total_laid_off DESC;

SELECT MAX(total_laid_off)
FROM phk_copyy2;


-- Mengubah tipe data kolom ke int

-- Periksa apakah ada nilai non-numerik
SELECT * 
FROM phk_copyy2 
WHERE CAST(total_laid_off AS UNSIGNED) IS NULL AND total_laid_off IS NOT NULL;

-- Ubah tipe data kolom setelah memastikan semua nilai valid
ALTER TABLE phk_copyy2 
MODIFY total_laid_off INT;


SELECT MAX(total_laid_off)
FROM phk_copyy2;

-- lihat persentase untuk melihat seberapa besar PHK
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM phk_copyy2
WHERE  percentage_laid_off IS NOT NULL;

SELECT *
FROM phk_copyy2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised DESC;



-- Company" dengan single Layoff terbesar
SELECT company, total_laid_off
FROM phk_copyy2
ORDER BY 2 DESC
LIMIT 5;


-- Company" with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM phk_copyy2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- by location
SELECT location, SUM(total_laid_off)
FROM phk_copyy2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;


SELECT country, SUM(total_laid_off)
FROM phk_copyy2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM phk_copyy2
GROUP BY YEAR(date)
ORDER BY 1 ASC;

SELECT industry, SUM(total_laid_off)
FROM phk_copyy2
GROUP BY industry
ORDER BY 2 DESC;


SELECT 
    stage, SUM(total_laid_off)
FROM
    phk_copyy2
GROUP BY stage
ORDER BY 2 DESC;





WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM phk_copyy2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;



-- Rolling Total of Layoffs Per Bulan
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM phk_copyy2
GROUP BY dates
ORDER BY dates ASC;

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM phk_copyy2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;