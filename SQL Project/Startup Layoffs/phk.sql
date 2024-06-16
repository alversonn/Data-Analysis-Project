SELECT 
    *
FROM
    phk
LIMIT 10;

-- Melihat jumlah baris
SELECT 
    COUNT(*)
FROM
    phk;

-- Membuat table baru untuk proses selanjutnya
CREATE TABLE phk_copyy
LIKE phk;

SELECT *
FROM phk_copyy;

-- Memasukkan data
INSERT phk_copyy
SELECT *
FROM phk;


-- ------------------------------DATA CLEANING-------------------------------- 					
-- STEP:
-- 1. Remove Duplicates
-- 2. Standarize Data
-- 3. Null/Blank Values
-- 4. Remove any Columns

-- Step 1. Remove Duplicates

-- Cek Duplikat
SELECT * FROM phk_copyy;

SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off,`date`) row_num
FROM phk_copyy;


SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off,`date`) row_num
	FROM phk_copyy
) duplicates
WHERE row_num > 1;

-- cek untuk oda untuk memastikan kembali
SELECT *
FROM phk_copyy
WHERE company = 'Oda';
-- terlihat entri tersebut bukan duplikat, harus memastikan untuk setiap baris.

-- duplikat yg benar
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised, 
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised, 
			) AS row_num
	FROM 
		phk_copyy
) duplicates
WHERE 
	row_num > 1;
    
-- Berikut row yg akan dihapus dengan row_num > 1 atau 2 atau lebih besar	
SELECT *
FROM phk_copyy
WHERE company = 'Beyond Meat';

SELECT *
FROM phk_copyy
WHERE company = 'Cazoo';


-- Penghapusan
WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised
			) AS row_num
	FROM 
		phk_copyy
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE
;

WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
	FROM phk_copyy
)
DELETE FROM phk_copyy
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised, row_num
	FROM DELETE_CTE
) AND row_num > 1;

-- Membuat & menambahkan kolom baru row_num, selanjutnya menghapus duplicate row_num lebih besar dari 1

ALTER TABLE phk_copyy ADD row_num INT;

SELECT *
FROM phk_copyy;


CREATE TABLE `phk_copyy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` int DEFAULT NULL
);

INSERT INTO `phk_copyy2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised
			) AS row_num
	FROM 
		phk_copyy;

-- Berikut dapat menghapus duplicate row_num lebih besar dari 1
DELETE FROM phk_copyy2 
WHERE
    row_num > 1;

-- cek
SELECT *
FROM phk_copyy2
WHERE company = 'Beyond Meat';

SELECT *
FROM phk_copyy2
WHERE company = 'Cazoo';

-- Sudah Terhapus


-- Step 2. Standarize Data
SELECT *
FROM phk_copyy2;

-- Berikut terlihat kolom industry memiliki row kosong 
SELECT DISTINCT
    industry
FROM
    phk_copyy2
ORDER BY 1;

SELECT *
FROM
    phk_copyy2
WHERE
    industry IS NULL OR industry = '';
    
-- Mengganti blank menjadi null    
UPDATE phk_copyy2
SET industry = NULL
WHERE industry = '';

-- Memastikan nilai tergantikan
SELECT *
FROM
    phk_copyy2
WHERE
    industry IS NULL OR industry = '';

-- Terlihat tidak ada industry yg memiliki variasi berbeda    
SELECT DISTINCT
    industry
FROM
    phk_copyy2
ORDER BY 1;    

-- Memperbaiki tipe data date
SELECT * 
FROM phk_copyy2;

SELECT `date`, STR_TO_DATE(`date`, '%Y-%m-%d')
FROM phk_copyy2;

-- Memakai string to date untuk update
UPDATE phk_copyy2
SET `date` = STR_TO_DATE(`date`, '%Y-%m-%d');

ALTER TABLE phk_copyy2
MODIFY COLUMN `date` DATE;

SELECT *
FROM phk_copyy2;


-- Step 3 Null/Blank values
SELECT *
FROM phk_copyy2;

-- Mengganti blank menjadi null    
UPDATE phk_copyy2
SET total_laid_off = NULL  
WHERE total_laid_off = '';

UPDATE phk_copyy2
SET percentage_laid_off = NULL 
WHERE percentage_laid_off = '';
 

-- Step 4 Remove any column and rows
SELECT *
FROM phk_copyy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Menghapus data yg tidak akan digunakan
DELETE FROM phk_copyy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM phk_copyy2;

-- Menghapus kolom row_num 
ALTER TABLE phk_copyy2
DROP COLUMN row_num;

SELECT * 
FROM phk_copyy2;
