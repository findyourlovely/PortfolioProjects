SELECT * FROM covid2021.deaths
WHERE continent is not null;

-- select data that we are going to be using to start
SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM covid2021.deaths d
ORDER BY 1,2;

-- import data and check for missing values
SELECT * FROM Covid.coviddeaths
order by 3, 4;

-- select specific data to use for project
SELECT 
	location,
    date, 
    total_cases,
    new_cases,
    total_deaths,
    population
FROM coviddeaths;


-- looking at total cases vs total deaths 
SELECT 
	location,
    date, 
    total_cases,
    total_deaths,
    (total_deaths / total_cases)*100 AS death_percentage
FROM coviddeaths
WHERE location like '%states%'
ORDER BY 1, 2 ;


-- looking at total cases vs total deaths
-- shows likelihood of dying if you get covid relative to country
SELECT 
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid2021.deaths
WHERE location like '%states%'
ORDER BY 1,2;

-- looking at total deaths vs population
SELECT 
	location, date, total_deaths, population, (total_deaths/population)*100 AS death_percentage
FROM covid2021.deaths
ORDER BY 1,2;

-- looking at total cases vs population in america
SELECT 
	location, date, total_cases, population, (total_cases/population)*100 AS case_rate
FROM covid2021.deaths
WHERE location like '%states%'
ORDER BY 1,2;
-- in this four month period the percentage of the population who had caught covid went up 3%

-- looking for the highest infection rates by country 
SELECT 
	location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population)*100) AS infection_rate
FROM covid2021.deaths
GROUP BY location, population
ORDER BY infection_rate DESC;

-- looking for highest death rates by country
SELECT 
	location, population, MAX(total_deaths) as death_count, MAX((total_deaths/population)*100) as death_rate
FROM covid2021.deaths
GROUP BY location, population
ORDER BY death_rate DESC;

-- looking for highest death counts by country
SELECT 
	location, MAX(total_deaths) as total_death_count
FROM covid2021.deaths
WHERE continent is not null AND location not like '%america%' AND location not like '%european%'
GROUP BY location
ORDER BY total_death_count DESC;

-- analyzing total deaths by continent
SELECT 
	continent, MAX(total_deaths) as total_death_count
FROM covid2021.deaths
WHERE continent is not null 
GROUP BY continent
ORDER BY total_death_count DESC;
-- austrailia is missing and an unknown row for continent is here

SELECT 
	location, MAX(total_deaths) as total_death_count
FROM covid2021.deaths 
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;

-- looking for continents with highest death count per population
SELECT continent, MAX(total_deaths) as total_death_count
FROM covid2021.deaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC;

-- global numbers of new cases and deaths by date
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage -- total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid2021.deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- total world death rate
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage -- total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid2021.deaths
WHERE continent is not null
ORDER BY 1,2;


-- looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vaccinations
FROM covid2021.deaths dea
JOIN covid2021.vaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3;

-- use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vaccinations
FROM covid2021.deaths dea
JOIN covid2021.vaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * , (Rolling_Vaccinations/Population)*100 as Percentage_Vaccinated
FROM PopvsVac;

-- create view to store data for later visulatizations

Create view PopvsVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_Vaccinations
FROM covid2021.deaths dea
JOIN covid2021.vaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null



