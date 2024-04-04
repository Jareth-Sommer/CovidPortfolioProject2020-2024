SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Data that will be used

SELECT location, date, population, new_cases, new_deaths, total_deaths, total_cases
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total cases vs total deaths per country

EXEC sp_help 'dbo.CovidDeaths'

ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_deaths float


SELECT location, date, population, new_cases, total_cases, new_deaths, total_deaths, (total_deaths/total_cases)*100 AS mortality_ratio
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total cases vs population per country
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infectious_ratio
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Highest infectious_ratio per country
SELECT location, population, MAX(total_cases) AS Highest_infection_number, MAX((total_cases/population))*100 AS Highest_infectious_ratio
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC


-- Highest death count per country
SELECT location, MAX(total_deaths) AS Total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Highest death count per continent
SELECT location, MAX(total_deaths) AS Total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- Global numbers
SELECT SUM(new_cases) AS Total_cases_global, SUM(new_deaths) AS Total_deaths_global, (SUM(new_deaths)/SUM(new_cases))*100 AS Total_mortality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

-- Examine data Covid vaccinations

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Vaccination percentage

SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, vac.total_vaccinations, vac.people_fully_vaccinated,
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vaccinations
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CTE

WITH Population_vs_Vaccination (Continent, Location, Date, Population, new_vaccinations, total_vaccinations, people_fully_vaccinated, rolling_count_vaccinations)
AS
(SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, vac.total_vaccinations, vac.people_fully_vaccinated,
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vaccinations
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (rolling_count_vaccinations/Population)*100
FROM Population_vs_Vaccination

