


SELECT * FROM PortfolioProject.dbo.CovidDeaths

--Looking at total cases vs total death
--Shows the liklehood of dying if you get covid in this country
SELECT  location , date ,population, total_cases, total_deaths , (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location= 'United States' AND  continent IS NOT NULL
ORDER BY 2 ASC

--Looking at total cases vs population
SELECT  location , date ,population, total_cases, total_deaths , (total_cases/population)*100 AS  infection_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location= 'United States' AND  continent IS NOT NULL
ORDER BY 2 ASC


--Looking at Countries with highest Infection Rate vs Population
SELECT  location ,population, MAX(total_cases) AS highest_infection, MAX((total_cases/population)*100) AS  infection_percentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location= 'United States'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY infection_percentage DESC

--looking at Countries with highest deaths
SELECT location , MAX(CAST(total_deaths AS BIGINT)) AS total_deaths 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY total_deaths  DESC


-- Looking at deaths in every continent
SELECT continent , SUM(CAST(new_deaths AS INT))  AS continent_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

CREATE VIEW contintet_total_deaths AS 
SELECT continent , SUM(CAST(new_deaths AS INT))  AS continent_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

SELECT * FROM contintet_total_deaths 
ORDER BY 2 DESC

-- GLOBAL NUMBERS 
SELECT date,SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases))*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases))*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1


--joining death table and vaccination table 
SELECT dea.continent , dea.location ,dea.date , dea.population, vac.total_vaccinations,vac.new_vaccinations
FROM PortfolioProject.dbo.CovidVaccinations AS vac
JOIN PortfolioProject.dbo.CovidDeaths dea 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Looking at Total population vs Vaccinations
SELECT dea.continent , dea.location ,dea.date , dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS vac
JOIN PortfolioProject.dbo.CovidDeaths dea 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

--Looking at people vaccinated in each country 
WITH popvsvac 
AS(
SELECT dea.continent , dea.location ,dea.date , dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS vac
JOIN PortfolioProject.dbo.CovidDeaths dea 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)
SELECT location , MAX((rolling_people_vaccinated/population)*100) AS vaccinated_percentage
FROM popvsvac
GROUP BY location
ORDER BY location

/*
SELECT * ,(rolling_people_vaccinated/population)*100 AS vaccinated_percentage
FROM popvsvac
ORDER BY location,date
*/

CREATE VIEW people_vaccinated AS
SELECT dea.continent , dea.location ,dea.date , dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject.dbo.CovidVaccinations AS vac
JOIN PortfolioProject.dbo.CovidDeaths dea 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 