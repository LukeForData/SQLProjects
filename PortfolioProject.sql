Select *
FROM PortfolioProject..['covid-data-deaths$']
WHERE Continent is not null
order by 3,4

--Select *
--FROM PortfolioProject..['covid-data-vaccinations$']
--order by 3,4

SELECT LOCATION, DATE, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['covid-data-deaths$']
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country

SELECT LOCATION, DATE, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPerc
FROM PortfolioProject..['covid-data-deaths$']
WHERE LOCATION like '%state%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT LOCATION, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS ContractedPerc
FROM PortfolioProject..['covid-data-deaths$']
--WHERE LOCATION like '%state%'
GROUP BY location, population
ORDER BY ContractedPerc DESC

-- Looking at countries with Highest Infection Rate compared to Population

SELECT LOCATION, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS ContractedPerc
FROM PortfolioProject..['covid-data-deaths$']
--WHERE LOCATION like '%state%'
GROUP BY location, population
ORDER BY ContractedPerc DESC

-- Showing Contries with Highest Death Count per Population

SELECT LOCATION, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..['covid-data-deaths$']
--WHERE LOCATION like '%state%'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Break Down above by Continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..['covid-data-deaths$']
--WHERE LOCATION like '%state%'
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Fix above break down

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..['covid-data-deaths$']
--WHERE LOCATION like '%state%'
WHERE Continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..['covid-data-deaths$']
--WHERE LOCATION like '%state%'
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, 
	SUM(cast(new_deaths as int))/SUM
	(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..['covid-data-deaths$']
WHERE continent is not null
--GROUP by date
order by 1,2

-- Join Tables


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..['covid-data-deaths$'] DEA
JOIN PortfolioProject..['covid-data-vaccinations$'] VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  ,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY DEA.location ORDER BY dea.location,
       dea.date)
FROM PortfolioProject..['covid-data-deaths$'] DEA
JOIN PortfolioProject..['covid-data-vaccinations$'] VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3

-- MAKE/USE CTE

WITH PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  ,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY DEA.location ORDER BY dea.location,
       dea.date)
FROM PortfolioProject..['covid-data-deaths$'] DEA
JOIN PortfolioProject..['covid-data-vaccinations$'] VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVSVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationvVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  ,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY DEA.location ORDER BY dea.location,
       dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['covid-data-deaths$'] DEA
JOIN PortfolioProject..['covid-data-vaccinations$'] VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
--WHERE DEA.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VIZ

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  ,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY DEA.location ORDER BY dea.location,
       dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['covid-data-deaths$'] DEA
JOIN PortfolioProject..['covid-data-vaccinations$'] VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
WHERE DEA.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated