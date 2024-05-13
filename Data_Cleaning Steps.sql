USE `data cleaning`;

Select company , Count(company)
from layoffs 
group by company 
having count(company)>1;

# FInding Duplicate Values
Select * from (Select *,
Row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as Row_Num from layoffs) layoffs
where Row_num>1;

Delete from layoffs
where Row_num >1 ;   # This does not work as Row_num column is not present in pur table

# Creating mirror table with added row_num column
CREATE TABLE `layoffs_1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  Row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# Inserting the data 
Insert into layoffs_1
Select *,
Row_number() over (partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as Row_Num from layoffs;

# Deleting Duplicates
Delete from layoffs_1
Where Row_num>2;

#Standardize the data 

Select Distinct company from layoffs_1;

Select company,TRIM(company) from layoffs_1;

Update layoffs_1
Set Company = Trim(Company);

Select Distinct industry from layoffs_1;

Select industry from layoffs_1
where industry like "Crypto%";

Update Layoffs_1
Set Industry = "Crypto"
Where Industry like "Crypto%";

Select Distinct country from layoffs_1;

Select Distinct Country ,Trim(Trailing '.' from `Country`) from layoffs_1;

# Removing '.' from country's name in the end
Update layoffs_1
Set Country = Trim(Trailing '.' from `Country`);

Select Date, str_to_date(`Date`, "%m/%d/%Y") from layoffs_1;

# Changing date format
Update Layoffs_1
Set `Date`= str_to_date(`Date`, "%m/%d/%Y");

# Changing Data type of Date
Alter table layoffs_1
Modify Column `Date`  Date;

# FInding Null Values 
Select * from layoffs_1
Where total_laid_off is null and percentage_laid_off is null;

# Deleting Null values 
Delete from Layoffs_1
WHere total_laid_off is null and percentage_laid_off is null;

# Finding Industry Null value and replacing with their industry
Select * from layoffs_1
where industry is null or industry='';

Select * from layoffs_1 as L1
Inner Join layoffs_1 as L2
on L1.company = L2.company
where (L1.industry is null or L1.industry = '')
and (L2.Industry is not null and L2.Industry<>'');

UPDATE layoffs_1 as L1
Inner Join layoffs_1 as L2
on L1.company = L2.company
Set L1.Industry = L2.Industry
where (L1.industry is null or L1.industry = '')
and (L2.Industry is not null and L2.Industry<>'');

# Dropping Column Row_num
Alter Table layoffs_1
Drop column Row_num;


