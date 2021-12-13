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
SELECT a.date, a.location, ISNULL(total_cases,0) 'Total Cases', ISNULL(population,0) 'Total Population', ISNULL(ROUND((total_cases/population)*100,2),0) 'Covid Rate'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) and a.location != 'International'
order by 'Covid Rate' desc

-- CREATE VIEW TO STORE CURRENT COVID PERCENTAGES AND POPULATION
CREATE VIEW NatCovRate as
SELECT a.date, a.location, ISNULL(total_cases,0) 'Total Cases', ISNULL(population,0) 'Total Population', ISNULL(ROUND((total_cases/population)*100,2),0) 'Covid Rate'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) and a.location != 'International'

SELECT * FROM NatCovRate order by 'Covid Rate' desc

-- Covid Percentage By Income
SELECT a.date, a.location, ISNULL(total_cases,0) 'Total Cases', ISNULL(population,0) 'Total Population', ISNULL(ROUND((total_cases/population)*100,2),0) 'Covid Rate'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) and a.location LIKE '%income%'
order by 'Covid Rate' desc

-- Most Virulent Months for Indonesia
SELECT a.date, ISNULL(total_cases,0) 'Total Cases', ISNULL(population,0) 'Total Population', ISNULL(ROUND((total_cases/population)*100,8),0) 'Covid Rate'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.iso_code = 'IDN'
order by 1

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

-- Total Covid Rate
SELECT a.date, a.location, ISNULL(total_cases,0) 'Total Cases', ISNULL(population,0) 'Total Population', ISNULL(ROUND((total_cases/population)*100,2),0) 'Covid Rate'
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date)
WHERE a.date = (SELECT MAX(date) max_date from DAPortf2..CovidDeathsAndCases most_recent_date where a.location = location) and a.location != 'International'
AND a.location IN ('Africa', 'North America', 'South America', 'Oceania','Asia','Europe')
order by 'Covid Rate' desc

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

SELECT a.location, a.date,  a.new_deaths, 
	SUM(a.new_deaths) OVER (PARTITION BY a.location order by a.location,a.date) 'Total deaths at location by this date'
from DAPortf2..CovidDeathsAndCases a
order by a.location, a.date

-- Global Rolling Mortality Rate
-- CTE usage in counting..

WITH cte_rolling_dead_ppl as (
SELECT a.location, a.date,  new_deaths, c.population,
	SUM(a.new_deaths) OVER (PARTITION BY a.location order by a.location,a.date) dateTotalDeaths
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date))
SELECT *, ROUND((dateTotalDeaths/population)*100,4) FROM cte_rolling_dead_ppl order by location, date

-- Average Global Rolling Mortality Rate

WITH cte_rolling_dead_ppl as (
SELECT a.location, a.date,  new_deaths, c.population,
	SUM(a.new_deaths) OVER (PARTITION BY a.location order by a.location,a.date) dateTotalDeaths,
	SUM(population) OVER (PARTITION BY a.location order by a.location,a.date) totalGlobalPop
from DAPortf2..CovidDeathsAndCases a
INNER JOIN DAPortf2..CovidPopData c
ON (a.iso_code = c.iso_code and a.date = c.date))
SELECT date, ROUND(AVG(dateTotalDeaths/totalGlobalPop),9) FROM cte_rolling_dead_ppl group by date order by date