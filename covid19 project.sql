select *
from portfolioproject..covid19data$

--looking at total cases vs total deaths 
--shows likelyhood of dying if virus is contracted
select Location, date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 as Deathpercentage
from portfolioproject..covid19data$
where location = 'canada'
order by 1, 2

-- looking at total cases vs population

select Location, date, Population, Total_Cases, (Total_Cases/Population)*100 as Deathpercentage
from portfolioproject..covid19data$
where location = 'canada'
order by 1, 2

-- looking at countires with highest infectiopn rate compared to population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM portfolioproject..covid19data$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- showing countries with the highest death count per population

SELECT 
    location,population, MAX(total_deaths) AS TotalDeathCount
FROM portfolioproject..covid19data$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

-- continent with the highest death count

SELECT Continent, sum (CAST(total_deaths AS INT)) AS TotalDeathCount
FROM portfolioproject..covid19data$
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC;

--global numbers per day
SELECT date, SUM(CAST(new_cases AS INT)) AS TotalCases,  SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100 AS DeathPercentage
FROM portfolioproject..covid19data$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

--total global numbers
SELECT SUM(CAST(new_cases AS INT)) AS TotalCases,SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100 AS DeathPercentage
FROM portfolioproject..covid19data$
WHERE continent IS NOT NULL;

--total vaccinations in countries
SELECT location, population, SUM(CAST(new_vaccinations AS BIGINT)) AS TotalVaccinations,
(SUM(CAST(new_vaccinations AS FLOAT)) / population) * 100 AS PercentVaccinated
FROM portfolioproject..covid19data$
WHERE new_vaccinations IS NOT NULL
GROUP BY location, population
ORDER BY PercentVaccinated DESC;

--CTE

WITH PopvsVac AS
(
SELECT continent, location, date, population, new_vaccinations,
    SUM(CAST(new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY location ORDER BY date) AS RollingPeopleVaccinated
FROM portfolioproject..covid19data$
WHERE continent IS NOT NULL
)

SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated,
    (RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM PopvsVac
ORDER BY location, date;

---- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)

SELECT
    continent,location, date, population, new_vaccinations,
    SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS RollingPeopleVaccinated
FROM portfolioproject..covid19data$
WHERE continent IS NOT NULL;

SELECT *,
(RollingPeopleVaccinated / Population) * 100 AS PercentVaccinated
FROM #PercentPopulationVaccinated
ORDER BY Location, Date;


-- creating view to store for data later

create view PercentPopulationVaccinated as
SELECT
    continent,location, date, population, new_vaccinations,
    SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date) AS RollingPeopleVaccinated
FROM portfolioproject..covid19data$
WHERE continent IS NOT NULL;
  select*
  from PercentPopulationVaccinated