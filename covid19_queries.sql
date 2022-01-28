-- percentage of people that contracted covid in US
SELECT location, date, total_cases, population, (total_cases/population * 100) AS covid_percentage
FROM `project2-339502.covid_deaths.covid_deaths`
WHERE location = 'United States'
ORDER BY 2

-- percentage of people that died after contracting covid in the US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) AS death_percentage
FROM `project2-339502.covid_deaths.covid_deaths`
WHERE location = 'United States'

-- total cases and deaths per country
SELECT location, SUM(total_deaths) AS covid_deaths, SUM(total_cases) AS covid_cases
FROM `project2-339502.covid_deaths.covid_deaths`
GROUP BY 1
ORDER BY 1

-- countries with highest death rate
SELECT location, population, MAX(total_deaths) as num_deaths, MAX((total_deaths/population * 100)) as death_rate
FROM `project2-339502.covid_deaths.covid_deaths`
WHERE continent is not null
GROUP BY 1,2
ORDER BY 4 DESC

--countries with highest infection rate
SELECT location, population, MAX(total_cases) as total_cases, MAX((total_cases/population * 100)) as max_case_perc
FROM `project2-339502.covid_deaths.covid_deaths`
WHERE continent is not null
GROUP BY 1,2
ORDER BY 4 DESC

--highest vaccination rate
SELECT loc, pop, max_vax, max_vax / pop * 100 AS perc_of_pop_vaxxed 
FROM
(SELECT vax.location loc, dea.population pop, MAX(people_vaccinated) max_vax, 
FROM `project2-339502.covid_deaths.covid_vax` vax
JOIN `project2-339502.covid_deaths.covid_deaths` dea
ON dea.location = vax.location
and dea.date = vax.date
WHERE dea.continent is not null
GROUP BY 1, 2
)
ORDER BY 4 DESC

--rolling vax by country
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS rolling_vax
FROM `project2-339502.covid_deaths.covid_deaths` dea
JOIN `project2-339502.covid_deaths.covid_vax` vax
ON dea.location = vax.location
AND dea.date = vax.date
WHERE dea.continent is not null
ORDER BY 2,3

-- info on vaccinations for 10 most populous countries
SELECT vax.location, date, people_vaccinated
FROM `project2-339502.covid_deaths.covid_vax` vax
JOIN 
(SELECT DISTINCT dea.location, dea.population 
FROM `project2-339502.covid_deaths.covid_deaths` dea
WHERE continent is not null 
ORDER BY 2 DESC
LIMIT 10) w
ON vax.location = w.location
ORDER BY 1,2