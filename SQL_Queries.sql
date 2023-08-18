/*
Covid 19 Data Exploration 
Skills used: Joins, Aggregate Functions, Date Functions, Creating Views, Converting Data Types, Subqueries
*/

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- Select Data that we are going to be starting with
SELECT Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Shows evolution of death percentage of people who contract covid in Colombia
SELECT location,
	date,
	total_cases,
	total_deaths,
	(total_deaths / total_cases) * 100 AS death_percentage
FROM CovidDeaths
WHERE location LIKE '%Colombia%'
	AND continent IS NOT NULL
ORDER BY 1, 2

-- Shows death percentage by year (at 21/11 for 2022) by country 
SELECT location,
	DATEPART(YEAR FROM date) AS year,
	MAX(date) AS date,
	MAX(total_cases) AS total_cases,
	MAX(total_deaths) AS total_deaths,
	(MAX(total_deaths) / MAX(total_cases)) * 100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, DATEPART(YEAR FROM date)
ORDER BY 1, 2

-- Shows countries with the highest death percentage 
SELECT location,
	MAX(total_cases) AS total_cases,
	MAX(total_deaths) AS total_deaths,
	(MAX(total_deaths) / MAX(total_cases)) * 100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_percentage DESC

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT Location,
	date,
	Population,
	total_cases,
	(total_cases / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%Colombia%'
ORDER BY 1, 2

-- Countries with Highest Infection Rate
SELECT 	--DATEPART(YEAR FROM date) AS year,
	location,
	population,
	MAX(total_cases) AS total_cases,
	MAX(total_cases / population) * 100 AS percent_population_infected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population --, DATEPART(YEAR FROM date)
ORDER BY percent_population_infected DESC
 

-- Countries with Highest Death Count per population 
SELECT Location,
	MAX(CAST(total_deaths AS INT)) AS total_deaths,
	MAX(CAST(total_deaths AS INT))/MAX(population/1000000) AS deaths_per_million
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY deaths_per_million DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
SELECT continent,
	SUM(CAST(new_cases AS FLOAT)) AS TotalCases,
	SUM(CAST(new_deaths AS FLOAT)) AS TotalDeathCount,
	SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100 AS DeathPercent,
	SUM(CAST(new_deaths AS INT))/SUM(DISTINCT population/1000000) AS TotalDeathCountPerMillion
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent


-- GLOBAL NUMBERS
SELECT SUM(total_cases) AS total_cases,
	SUM(total_cases) / SUM(population) * 100 AS percent_population_infected,
	SUM(total_cases) / SUM(population/1000000) AS cases_per_million,
	SUM(total_deaths) AS total_deaths,
	SUM(total_deaths) / SUM(total_cases) * 100 AS death_percentage,
	SUM(total_deaths) / SUM(population/1000000) AS deaths_per_million_population
FROM (
	SELECT 	--DATEPART(YEAR FROM date) AS year,
		D.location,
		MAX(population) AS population,
		MAX(total_cases) AS total_cases,
		MAX(CAST(total_deaths AS INT)) AS total_deaths	
	FROM CovidDeaths D
	JOIN CovidVaccinations V
	ON D.location = V.location
	WHERE D.continent IS NOT NULL --AND location LIKE '%Colombia%'
	GROUP BY D.location --, DATEPART(YEAR FROM date)
) t



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine by country and date
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	people_vaccinated,
	(people_vaccinated / population) * 100 AS percent_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Shows Percentage of Population (by country) that has recieved at least one Covid Vaccine to date (2022-11-20) 
SELECT dea.continent,
	dea.location,
	MAX(dea.date),
	dea.population,
	MAX(CAST(people_vaccinated AS BIGINT)) AS people_vaccinated, 
	MAX(CAST(people_vaccinated AS BIGINT) / population) * 100 AS percent_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, 
	dea.location, 
	dea.population

-- Shows Percentage of Population (Global) that has recieved at least one Covid Vaccine to date (2022-11-20)
SELECT SUM(population) AS population, 
	SUM(people_vaccinated) AS people_vaccinated,  
	(SUM(people_vaccinated) / SUM(population)) * 100 AS percent_people_vaccinated
FROM (
	SELECT dea.continent,
		dea.location,
		dea.population,
		MAX(CAST(people_vaccinated AS BIGINT)) AS people_vaccinated, 
		MAX(CAST(people_vaccinated AS BIGINT) / population) * 100 AS percent_people_vaccinated
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	GROUP BY dea.continent, 
		dea.location, 
		dea.population
) t


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	people_vaccinated,
	(people_vaccinated / population) * 100 AS percent_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL