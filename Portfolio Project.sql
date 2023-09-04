SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 

-- 1) Looking at the Total Cases VS Total Deaths (percentage of deaths per case).
-- Shows the likelihood of dying if you contract COVID in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Pakistan%'
ORDER BY 1,2 

-- 2) Looking at the Total Cases VS Population.
-- Shows what percentage of population got COVID
SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Pakistan%'
ORDER BY 1,2 

-- 3) Looking at countries with highest Infection Rate compared to Population.
SELECT Location, MAX(total_cases) as HighestInfectionCount, Population, (MAX(total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Pakistan%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- 4) Looking at countries with highest Death Count per Population.
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where Continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
-- Death Percentage of the world
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY Date
ORDER BY 1,2 


-- Joining both tables
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.location
	AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations
-- Total amount of people in the world who have been vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2 

--USE CTE
WITH PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacinations numeric,
RollingPeopleVaccinated numeric
) 

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visuals

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2 

SELECT *
FROM PercentPopulationVaccinated