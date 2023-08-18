-- Gloabl Numbers
SELECT SUM(total_cases) AS total_cases,
	(SUM(total_cases) / SUM(population)) * 100  AS percent_population_infected,
	SUM(total_deaths) AS total_deaths,
	SUM(total_deaths) / SUM(total_cases) * 100 AS death_percentage,
	SUM(total_deaths) / SUM(population/1000000) AS deaths_per_million_population,
	SUM(people_vaccinated) AS people_vaccinated,
	(SUM(people_vaccinated) / SUM(population)) * 100 AS percent_people_vaccinated
FROM (
	SELECT 	--DATEPART(YEAR FROM date) AS year,
		D.location,
		MAX(population) AS population,
		MAX(total_cases) AS total_cases,
		MAX(CAST(total_deaths AS INT)) AS total_deaths,
		MAX(CAST(people_vaccinated AS BIGINT)) AS people_vaccinated
	FROM CovidDeaths D
	JOIN CovidVaccinations V
	ON D.location = V.location
	WHERE D.continent IS NOT NULL 
	GROUP BY D.location --, DATEPART(YEAR FROM date)
) t

-- Showing contintents with the highest death count per population
SELECT continent,
	SUM(CAST(new_cases AS FLOAT)) AS TotalCases,
	SUM(CAST(new_deaths AS FLOAT)) AS TotalDeathCount,
	SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100 AS DeathPercent,
	SUM(CAST(new_deaths AS INT))/SUM(DISTINCT population/1000000) AS TotalDeathCountPerMillion
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

-- Population infected and deaths by country 
SELECT 	
	location,
	population,
	MAX(total_cases) AS total_cases,
	MAX(total_cases / population) * 100 AS percent_population_infected,
	MAX(CAST(total_deaths AS INT)) AS total_deaths,
	(MAX(CAST(total_deaths AS INT)) / MAX(total_cases)) * 100 AS death_percentage,
	MAX(CAST(total_deaths AS INT))/MAX(population/1000000) AS deaths_per_million
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population 
ORDER BY percent_population_infected DESC

-- Population infected and deaths by country and date
SELECT 	
	location,
	population,
	date,
	MAX(total_cases) AS total_cases,
	MAX(total_cases / population) * 100 AS percent_population_infected,
	MAX(CAST(total_deaths AS INT)) AS total_deaths,
	(MAX(CAST(total_deaths AS INT)) / MAX(total_cases)) * 100 AS death_percentage,
	MAX(CAST(total_deaths AS INT))/MAX(population/1000000) AS deaths_per_million
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY percent_population_infected DESC

-- GDP per capita and deaths by country 
SELECT D.location, 
	AVG(population) AS population,
	AVG(gdp_per_capita) AS gdp_per_capita,
	(MAX(CAST(people_vaccinated AS BIGINT)) / AVG(population)) * 100 AS percent_people_vaccinated,
	(MAX(CAST(total_deaths AS INT)) / MAX(total_cases)) * 100 AS death_percentage, 
	MAX(CAST(total_deaths AS INT)) / MAX(population/1000000) AS deaths_per_million,
	MAX(total_cases / population) * 100 AS percent_population_infected
FROM CovidDeaths D
JOIN CovidVaccinations V
ON D.location = V.location
WHERE D.continent IS NOT NULL
GROUP BY D.location
