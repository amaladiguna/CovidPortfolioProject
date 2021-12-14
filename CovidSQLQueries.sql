-- Select all script
SELECT TOP (5000) *
  FROM DAPortf2..CovidDeathsAndCases a
  INNER JOIN DAPortf2..CovidTestsAndVaccinations b
  ON (a.iso_code = b.iso_code and a.date = b.date)
  INNER JOIN DAPortf2..CovidPopData c
  ON (a.iso_code = c.iso_code and a.date = c.date)
  ORDER BY a.location, a.date;

WITH cte_max_date as (SELECT location, MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date group by location)
SELECT * FROM cte_max_date 

-- Mortality rate by country
SELECT date, location, ISNULL(total_deaths,0) 'Total Deaths', ISNULL(total_cases,0) 'Total Cases', ISNULL(ROUND((total_deaths/total_cases)*100,2),0) 'Mortality Rate'
from DAPortf2..CovidDeathsAndCases a
WHERE date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location)
order by 'Mortality Rate' desc

-- CREATE VIEW TO STORE TOTAL DEATHS AND CASES HERE
CREATE VIEW NatMortRate as
SELECT date, location, ISNULL(total_deaths,0) 'Total Deaths', ISNULL(total_cases,0) 'Total Cases', ISNULL(ROUND((total_deaths/total_cases)*100,2),0) 'Mortality Rate'
from DAPortf2..CovidDeathsAndCases a
WHERE date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location)

SELECT * FROM NatMortRate order by 'Mortality Rate' desc

-- Deadliest Months for Indonesia by Covid Mortality Rate
SELECT date, location, ISNULL(total_deaths,0) 'Total Deaths', ISNULL(total_cases,0) 'Total Cases', ISNULL(ROUND((total_deaths/total_cases)*100,2),0) 'Mortality Rate'
from DAPortf2..CovidDeathsAndCases a
WHERE iso_code = 'IDN'
order by 'Mortality Rate' DESC

-- Covid Percentage Right Now
SELECT a.date, a.location, ISNULL(total_cases-total_deaths,0) 'Total Cases', ISNULL(total_cases,0) 'Total Population', ISNULL(ROUND(((total_cases-total_deaths)/total_cases)*100,2),0) 'Recovery Rate'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) and a.location != 'International'
order by 'Recovery Rate' desc

-- CREATE VIEW TO STORE CURRENT COVID PERCENTAGES AND POPULATION
CREATE VIEW NatCovRate as
SELECT a.date, a.location, ISNULL(total_cases-total_deaths,0) 'Total Cases', ISNULL(total_cases,0) 'Total Population', ISNULL(ROUND(((total_cases-total_deaths)/total_cases)*100,2),0) 'Recovery Rate'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) and a.location != 'International'

SELECT * FROM NatCovRate order by 'Recovery Rate' desc

-- Covid Recovery Rate By Income
SELECT a.date, a.location, ISNULL(total_cases-total_deaths,0) 'Total Cases', ISNULL(total_cases,0) 'Total Population', ISNULL(ROUND(((total_cases-total_deaths)/total_cases)*100,2),0) 'Recovery Rate'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) and a.location LIKE '%income%'
order by 'Recovery Rate' desc

-- Dead People Rate
SELECT a.date, a.location, ISNULL(total_deaths,0) 'Total Cases', ISNULL(population,0) 'Total Population', ISNULL(ROUND((total_deaths/population)*100,2),0) 'Population Culled'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) and a.location != 'International'
order by 'Population Culled' desc

-- Continent Sort

-- Mortality Rate by Continent
SELECT date, location, ISNULL(total_deaths,0) 'Total Deaths', ISNULL(total_cases,0) 'Total Cases', ISNULL(ROUND((total_deaths/total_cases)*100,2),0) 'Mortality Rate'
from DAPortf2..CovidDeathsAndCases a
WHERE date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) 
AND location IN ('Africa', 'North America', 'South America', 'Oceania','Asia','Europe')
order by 'Mortality Rate' desc

-- Recovery Rate by Continent
SELECT a.date, a.location, ISNULL(total_cases-total_deaths,0) 'Total Cases', ISNULL(total_cases,0) 'Total Population', ISNULL(ROUND(((total_cases-total_deaths)/total_cases)*100,2),0) 'Recovery Rate'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) and a.location != 'International'
AND a.location IN ('Africa', 'North America', 'South America', 'Oceania','Asia','Europe')
order by 'Recovery Rate' desc

-- GLOBAL STATS

-- Global Mortality Rate over time
-- Sum of all nation's new cases/sum of all nation's deaths
SELECT a.date,  ISNULL(SUM(a.new_cases),0) newCaseSum, ISNULL(SUM(a.new_deaths),0) newDeathSum, CASE 
	WHEN SUM(a.new_cases) = 0 OR SUM(a.new_cases) IS NULL THEN 0
	ELSE ROUND(SUM(a.new_deaths)/SUM(a.new_cases),3)
END 'Mortality Rate'
from DAPortf2..CovidDeathsAndCases a
group by a.date
order by a.date

-- Global Rolling Count of Dead People
-- Sum of all nation's new cases/sum of all nation's deaths

SELECT a.location, a.date,  a.new_cases, 
	SUM(a.new_cases) OVER (PARTITION BY a.location order by a.location,a.date) 'Total Cases at Location by This Date'
from DAPortf2..CovidDeathsAndCases a
order by a.location, a.date

-- Global Rolling Crude Infection Rate
-- CTE usage in counting..

00

-- Average Global Cases Per Million
-- Continent
WITH cte_rolling_ as (
SELECT a.location, a.date,  (total_cases-new_cases)-new_deaths, c.population,
	SUM(a.new_deaths) OVER (PARTITION BY a.location order by a.location,a.date) dateTotalDeaths,
	SUM(population) OVER (PARTITION BY a.location order by a.location,a.date) totalGlobalPop
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.location NOT IN ('European Union') and a.continent 
)
SELECT date, ROUND(AVG(dateTotalDeaths/totalGlobalPop),9) FROM cte_rolling_dead_ppl group by date order by date

-- Global Covid Mortality Rate
Select SUM(new_cases) 'Total Cases', SUM(new_deaths) 'Total Deaths', SUM(new_deaths)/SUM(New_Cases)*100 'Global Covid Mortality Rate'
From DAPortf2..CovidDeathsAndCases
--Where location like '%states%'
where continent is not null 
--Group By date
order by 'Total Cases','Total Deaths'