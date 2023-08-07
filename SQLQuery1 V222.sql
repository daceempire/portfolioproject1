SELECT location, continent, date, total_cases, new_cases, total_deaths, population, new_cases, new_deaths
FROM CovidDeath
order by 1,2

SELECT * FROM CovidDeath

--looking at total cases vs total death
--i.e look at likelihood of death if contracted 

alter table CovidDeath
alter column total_cases numeric

alter table CovidDeath
alter column total_deaths numeric

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent
FROM CovidDeath
where total_cases <> 0 and total_deaths <> 0
group by date, location, total_cases, total_deaths
order by 1,2

--looking at total cases against the population of each countries

alter table CovidDeath
alter column population numeric

SELECT location, date, total_cases, population, (total_cases/population)*100 as percentageInfected
FROM CovidDeath
WHERE continent IS NOT NULL
order by location

--looking at country with higest infection rate per population

WITH COVID AS (
SELECT location, total_cases, population
FROM CovidDeath)
SELECT location, MAX(total_cases) as highest_cases, population, MAX((total_cases/population)*100) AS highest_infection_rate
FROM COVID
GROUP BY location, population
ORDER BY highest_infection_rate desc

-- LOOKING AT COUNTRIES WITH HIGHEST DEATH PER POPULATION VOLUME

SELECT location, total_deaths, population, max((total_deaths/population)*100) as highest_death_rate
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population, total_deaths
ORDER BY highest_death_rate desc

SELECT DISTINCT continent, MAX(total_deaths) AS Death_countt
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Death_countt

--GLOBAL NUMBERS

alter table CovidDeath
alter column new_cases NUMERIC

SELECT date, location, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(NULLIF(new_cases,0))*100 AS deathPercentage
FROM CovidDeath
--where new_deaths > 0 AND new_cases > 0
group by date, location
order by date, location

alter table CovidVaccination
alter column new_vaccinations NUMERIC

--looking at total population against total vaccination

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, new_vaccinations
, SUM(new_vaccinations) /*OVER(PARTITION BY DEA.location order by DEA.location, DEA.date)*/ AS Total_new_vaccination
FROM CovidDeath AS DEA
JOIN CovidVaccination AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
group by DEA.continent, DEA.location, DEA.date, DEA.population, new_vaccinations
order by 2,3

--USING CTE

WITH POPVAC (Continent, Location, Date, Population, New_vaccinations, Total_new_vaccination)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER(PARTITION BY DEA.location order by DEA.location, DEA.date) AS Total_new_vaccination
FROM CovidDeath AS DEA
JOIN CovidVaccination AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
--order by location, date
)
SELECT *, (Total_new_vaccination/Population)*100 AS PERCENTAGE_VACCINATED
FROM POPVAC
order by location, date

--using temp tables

DROP TABLE IF EXISTS #PercentPopVac
CREATE TABLE #PercentPopVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalNewVaccination numeric
)

INSERT INTO #PercentPopVac
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER(PARTITION BY DEA.location order by DEA.location, DEA.date) AS TotalNewVaccination
FROM CovidDeath AS DEA
JOIN CovidVaccination AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
--order by location, date

SELECT *, (TotalNewVaccination/population)*100 AS PERCENTAGE_VACCINATED
FROM #PercentPopVac
order by location, date

--CREATING VIEWS TO STORE DATE FOR LATER VISUALIZATION

CREATE VIEW PercentPopVac AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER(PARTITION BY DEA.location order by DEA.location, DEA.date) AS TotalNewVaccination
FROM CovidDeath AS DEA
JOIN CovidVaccination AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
--order by location, date

SELECT * FROM PercentPopVac