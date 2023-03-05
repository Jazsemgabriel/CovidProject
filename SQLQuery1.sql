SELECT *
FROM PortfolioProjectCovid1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProjectCovid1..CovidVacunas
--ORDER BY 3, 4

--Select data that i going to be using

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProjectCovid1..CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProjectCovid1..CovidDeaths
--WHERE location = 'Peru'
ORDER BY 1,2

-- Looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS cases_percentage
FROM PortfolioProjectCovid1..CovidDeaths
--WHERE location = 'Peru'
ORDER BY 1,2

-- Countries with highest infection rates compared to population -- 

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS percent_population_infected
FROM PortfolioProjectCovid1..CovidDeaths
--WHERE location = 'Venezuela'
GROUP BY population, location
ORDER BY percent_population_infected DESC

-- Countries with highest death count -- 

SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM PortfolioProjectCovid1..CovidDeaths
--WHERE location = 'Venezuela'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Drill down by continent -- 

SELECT continent, MAX(cast(total_deaths AS int)) AS total_death_count
FROM PortfolioProjectCovid1..CovidDeaths
--WHERE location = 'Venezuela'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

-- Global numbers -- 

-- Total cases vs total deaths

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
                  SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage
FROM PortfolioProjectCovid1..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vacunas --

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
       SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date ) AS sum_vaccinations_per_country
FROM PortfolioProjectCovid1..CovidDeaths AS d
JOIN PortfolioProjectCovid1..CovidVacunas AS v
     ON d.location = v.location AND
	  d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3

-- Using CTE 

WITH population_vaccinated (continent, location, date, population, new_vaccinations, sum_vaccinations_per_country) AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
       SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date ) AS sum_vaccinations_per_country
FROM PortfolioProjectCovid1..CovidDeaths AS d
JOIN PortfolioProjectCovid1..CovidVacunas AS v
     ON d.location = v.location AND
	  d.date = v.date
WHERE d.continent IS NOT NULL)
SELECT *, (sum_vaccinations_per_country/population)*100 AS perc_people_vaccinated
FROM population_vaccinated


-- Creating a Table --

CREATE TABLE #PercentPopulationVaccinated (
contintent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
sum_vaccinations_per_country numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
       SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date ) AS sum_vaccinations_per_country
FROM PortfolioProjectCovid1..CovidDeaths AS d
JOIN PortfolioProjectCovid1..CovidVacunas AS v
     ON d.location = v.location AND
	  d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3

SELECT *, (sum_vaccinations_per_country/population)*100 AS perc_people_vaccinated
FROM #PercentPopulationVaccinated


-- Creating a View --

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
       SUM(CONVERT(BIGINT, v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date ) AS sum_vaccinations_per_country
FROM PortfolioProjectCovid1..CovidDeaths AS d
JOIN PortfolioProjectCovid1..CovidVacunas AS v
     ON d.location = v.location AND
	  d.date = v.date
WHERE d.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated