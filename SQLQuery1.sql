SELECT * FROM CovidDeaths 
WHERE continent IS NOT NULL 
ORDER BY 3,4;
---------------------------

SELECT SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths FROM CovidDeaths;
---------------------------
--Percentage Of Deaths Per Cases 
SELECT 
    location,
    date,
    new_cases,
    new_deaths,
    (new_deaths * 100.0 / NULLIF(new_cases, 0)) 
        AS PercentageOfDeathsPerCases
FROM CovidDeaths
WHERE location = 'Egypt'
AND continent IS NOT NULL
ORDER BY location, date;
-----------------------------
--Percentage Of Cases Per Population 

SELECT location,date,new_cases,population,(new_cases/population)*100 AS PercentageOfCasesPerPopulation 
FROM CovidDeaths 
--IN EGYPT
WHERE location='Egypt' AND continent IS NOT NULL 
ORDER BY 2 ASC;
-----------------------------
--Countries With Highest Infection Rate Compared To Population
SELECT location,population,MAX(new_cases) AS HighestInfectionCount,population,MAX((new_cases/population))*100 AS HighestInfectionRate  
FROM CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY location,population
ORDER BY HighestInfectionRate DESC;
-------------------
--Countries With Highets Death Count Per Population
SELECT location,population,MAX(new_deaths) AS HighestDeathCount,MAX((new_deaths/population))*100 AS HighestDeathRate  
FROM CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY location,population
ORDER BY HighestDeathRate DESC;

--------------------

--CONTINENTS WITH HIGHEST DEATH COUNT
SELECT continent,MAX(total_deaths) AS HighestDeathPerContinent 
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathPerContinent DESC
--------------------

--GLOBAL MUMBERS
SELECT     
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

---------------------
--Total Population Per Vaccination
SELECT cdeath.continent ,cdeath.location,cdeath.date,cdeath.population,cvaccination.new_vaccinations 
,SUM(CAST(cvaccination.new_vaccinations AS INT) ) OVER (Partition BY cdeath.location ORDER BY cdeath.location , cdeath.date ) AS RollingPeopleVaccination
FROM CovidDeaths cdeath
join CovidVaccinations cvaccination 
on cdeath.location=cvaccination.location
AND cdeath.date=cvaccination.date
WHERE cdeath.continent IS NOT NULL
ORDER BY 2,3

-----------------------
--CTE
WITH PopulationVSVaccination(continent,location,date,population,new_vaccinations,RollingPeopleVaccination)
AS (
SELECT cdeath.continent ,cdeath.location,cdeath.date,cdeath.population,cvaccination.new_vaccinations 
,SUM(CAST(cvaccination.new_vaccinations AS INT) ) OVER (Partition BY cdeath.location ORDER BY cdeath.location , cdeath.date ) AS RollingPeopleVaccination
FROM CovidDeaths cdeath
join CovidVaccinations cvaccination 
on cdeath.location=cvaccination.location
AND cdeath.date=cvaccination.date
WHERE cdeath.continent IS NOT NULL 
--ORDER BY 2,3

) 
SELECT *,(RollingPeopleVaccination/population)*100 AS PCTVaccinated
FROM PopulationVSVaccination


--------------------------------
--Creating Temp Table
DROP TABLE IF EXISTS #PCTVaccinated
CREATE TABLE  #PCTVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccination NUMERIC,
RollingPeopleVaccination NUMERIC
)
INSERT INTO #PCTVaccinated 
SELECT cdeath.continent ,cdeath.location,cdeath.date,cdeath.population,cvaccination.new_vaccinations 
,SUM(CAST(cvaccination.new_vaccinations AS INT) ) OVER (Partition BY cdeath.location ORDER BY cdeath.location , cdeath.date ) AS RollingPeopleVaccination
FROM CovidDeaths cdeath
join CovidVaccinations cvaccination 
on cdeath.location=cvaccination.location
AND cdeath.date=cvaccination.date
WHERE cdeath.continent IS NOT NULL
ORDER BY 2,3


SELECT *,(RollingPeopleVaccination/population)*100 AS PCTVaccinated
FROM #PCTVaccinated

------------------------------

-- Creating A View
CREATE VIEW PCTVACCINATED AS 
--Total Population Per Vaccination
SELECT cdeath.continent ,cdeath.location,cdeath.date,cdeath.population,cvaccination.new_vaccinations 
,SUM(CAST(cvaccination.new_vaccinations AS INT) ) OVER (Partition BY cdeath.location ORDER BY cdeath.location , cdeath.date ) AS RollingPeopleVaccination
FROM CovidDeaths cdeath
join CovidVaccinations cvaccination 
on cdeath.location=cvaccination.location
AND cdeath.date=cvaccination.date
WHERE cdeath.continent IS NOT NULL


--DELETE FROM Covid
--DELETE FROM Covid
--DELETE FROM Covid


