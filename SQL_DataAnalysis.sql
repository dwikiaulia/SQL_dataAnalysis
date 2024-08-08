USE datageek;

-- DATA CLEANING AND TRANSFORMATION
-- converting funding in millions(M) into billions(B)
UPDATE Unicorn_Companies
SET Funding = ROUND(Funding / 1000.0, 2)
WHERE Funding NOT LIKE '%B';
UPDATE Unicorn_Companies
SET Funding = CONVERT(DECIMAL(10, 2), Funding)
WHERE Funding NOT LIKE '%B';

-- removing company with 'unknown' and '0' funding
DELETE FROM Unicorn_Companies
WHERE Funding = 'Unknown';
DELETE FROM Unicorn_Companies
WHERE Funding = '0';
DELETE FROM Unicorn_Companies
WHERE Company = 'Zapier';

-- replacing $ sign and 'B' sign on valuation
UPDATE Unicorn_Companies
SET Valuation = REPLACE(REPLACE(Valuation, '$', ''), 'B', '');

-- replacing 'B' sign and 'M' sign on funding
UPDATE Unicorn_Companies
SET Funding = REPLACE(REPLACE(Funding, 'B', ''), 'M', '')
WHERE Funding LIKE '%B';

EXEC sp_help Unicorn_Companies;

-- converting data type in 'valuation' col from nvarchar into decimal
ALTER TABLE Unicorn_Companies
ALTER COLUMN Valuation DECIMAL (10, 2);

-- converting data type in 'funding' col from nvarchar into decimal
ALTER TABLE Unicorn_Companies
ALTER COLUMN Funding DECIMAL (10, 2);


-- DATA ANALYSIS
-- find TOP 5 company by valuation in billions(B)
SELECT TOP 5 company, Valuation, Industry
FROM Unicorn_Companies
ORDER BY Valuation DESC;

-- finding unicorns by industries
SELECT Industry, count(Industry) AS total_company
FROM Unicorn_Companies
GROUP BY Industry
ORDER BY total_company DESC;

-- finding unicorns by the continent
SELECT Continent, COUNT(company) AS total_company
FROM Unicorn_Companies
GROUP BY Continent
ORDER BY total_company DESC;

-- find TOP 5 countries by unicorns
SELECT TOP 5 country, COUNT(company) AS total_company
FROM Unicorn_Companies
GROUP BY Country
ORDER BY total_company desc;

-- avg years taken to being unicorn companies
SELECT AVG(YEAR(date_joined) - (year_founded)) AS year_avg
FROM Unicorn_Companies;

-- find the trend (in years) that most of unicorn rise  
SELECT COUNT(company) AS company_count, YEAR(date_joined) AS Year_joined
FROM Unicorn_Companies
GROUP BY YEAR(date_joined)
ORDER BY Year_joined;


-- find TOP 10 company and investor that has the highest ROI in percent
WITH CTE AS (
    SELECT Company,
        CAST(Valuation AS DECIMAL(10, 2)) AS Valuation,
        CAST(Funding AS DECIMAL(10, 2)) AS Funding,
		Select_Investors,
		Industry
    FROM
        Unicorn_Companies
)
SELECT
    TOP 10 Company, Valuation, Funding, Select_Investors, Industry,
	ROUND((Valuation - Funding)/Funding * 100,0) AS ROI
FROM
    CTE
	ORDER BY ROI DESC;

-- find countries which cities have most unicorn
SELECT TOP 5 City, Country, COUNT(Company) AS Unicorn
FROM Unicorn_Companies
GROUP BY Country, City
ORDER BY Unicorn DESC;

-- calculate year on year changes on unicorn
SELECT
  YEAR(Date_Joined) AS Years,
  COUNT(*) AS No_unicorn,
  LAG(COUNT(*), 1, 0) OVER (ORDER BY YEAR(Date_Joined)) AS Previous_Year,
  COUNT(*) - LAG(COUNT(*), 1, 0) OVER (ORDER BY YEAR(Date_Joined)) AS YoY_change
FROM
  Unicorn_Companies
GROUP BY
  YEAR(Date_Joined)
ORDER BY
  YEAR(Date_Joined);























