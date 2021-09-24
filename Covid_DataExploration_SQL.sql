SELECT * FROM CovidDeaths
Order by 3,4;

SELECT * FROM CovidVaccination
Order by 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Total Cases Vs Total Deaths per country
-- Results shows likelihood of dying if you contact with covid in your country
SELECT location, date, total_cases, total_deaths, population,round((total_deaths / total_cases) * 100,2) AS DeathPercentage
FROM CovidDeaths
WHERE location like '%india%'
ORDER BY location

-- Total Cases VS Population
-- Percentage of people who infected by Covid
SELECT location,date,total_cases,population, round((total_cases / population) * 100, 2) AS TotalCasePercentage
FROM CovidDeaths
--WHERE location like '%india%'
ORDER BY location

-- Countries which has high number of infected rates per population
SELECT location,MAX(total_cases) AS HighestInfectionCount,population, 
MAX(round((total_cases / population) * 100, 2)) AS PercentagePopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- Highest number of deaths categorized by country
SELECT location, MAX(cast(total_deaths as int)) AS DeathCount 
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY DeathCount DESC

-- Highest number of deaths by continet
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Countries which has high number of deaths per population
SELECT location, MAX(total_deaths) AS HighestDeathsCount,population,
MAX(round((total_deaths / population) * 100, 2)) AS PercenagePopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercenagePopulationInfected DESC

-- Global Total cases and Total deaths
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,  
ROUND(SUM(cast(new_deaths as int)) / SUM(new_cases) * 100,2) AS PercentageOfDeaths
FROM CovidDeaths

-- Total population with Vaccinations
SELECT cd.continent, cd.location,cd.population, cv.new_vaccinations
FROM CovidDeaths AS cd 
INNER JOIN CovidVaccination cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null


-- Get Rolling People who got vaccinated by country
SELECT cd.continent, cd.location,cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition By cd.location Order By cd.location, cd.date) AS Roll
FROM CovidDeaths AS cd 
INNER JOIN CovidVaccination cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null

-- Using CTE
With PopVsVac (Continent, Location, Population, New_Vaccinations, RollingPeopleCount)
as(
SELECT cd.continent, cd.location,cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition By cd.location Order By cd.location, cd.date) AS RollingPeopleCount
FROM CovidDeaths AS cd 
INNER JOIN CovidVaccination cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null
)
SELECT *, (RollingPeopleCount / Population) * 100 AS PercentageOfPeopleGotVaccinated
FROM PopVsVac

-- Using TEMP Table
CREATE TABLE #PercentageOfPeopleVacciated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentageOfPeopleVacciated
SELECT cd.continent, cd.location,cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition By cd.location Order By cd.location, cd.date) AS RollingPeopleCount
FROM CovidDeaths AS cd 
INNER JOIN CovidVaccination cv
ON cd.location = cv.location AND cd.date = cv.date

-- Creating View
Create View PercentageOfPeopleVacciated AS
SELECT cd.continent, cd.location,cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition By cd.location Order By cd.location, cd.date) AS RollingPeopleCount
FROM CovidDeaths AS cd 
INNER JOIN CovidVaccination cv
ON cd.location = cv.location AND cd.date = cv.date





