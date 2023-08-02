--Checking Total Cases Vs Total Deaths In Nigeria
--Shows Likelyhood of dying from Covid In Nigeria
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM kelechis-first-project.demos.CovidDeaths
 WHERE Location = "Nigeria" and continent is not null
  order by 1,2;

--Looks at Countries with Highest Infection Rate compared to Population
SELECT Location, Population,MAX(total_cases) as HighestInfectionCount,Max((total_cases/Population))*100 as PercentPopulationInfected
 FROM kelechis-first-project.demos.CovidDeaths
 where continent is not null
 --WHERE Location like "States"
 Group by Location, Population
  order by PercentPopulationInfected DESC;

  --Countries with Highest Death Count per population
  SELECT Location,MAX(total_deaths) as TotalDeathCount
 FROM kelechis-first-project.demos.CovidDeaths
 WHERE continent is not null
 --WHERE Location like "States"
 Group by Location
  order by TotalDeathCount DESC;

  --Continents with Highest Death Count per population
  SELECT Continent,MAX(total_deaths) as TotalDeathCount
 FROM kelechis-first-project.demos.CovidDeaths
 WHERE continent is not null
 --WHERE Location like "States"
 Group by Continent
  order by TotalDeathCount DESC;

  --GLOBAL NUMBERS
SELECT SUM(new_cases)as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage--Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM kelechis-first-project.demos.CovidDeaths
 WHERE continent is not null
 --Group By date
  order by 1,2;

--Looking at Total Population vs Vaccinations
  Select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, 
  --(RollingPeopleVaccinated/population)*100
  from `kelechis-first-project.demos.CovidDeaths` dea
  JOIN `kelechis-first-project.demos.CovidVaccinations` Vac
  on dea.location = Vac.location
  and dea.date = Vac.date
  where dea.continent is not null
  order by 2,3;

  --USE CTE
  With PopVsVac
  as
  (
  Select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, 
  --(RollingPeopleVaccinated/population)*100
  from `kelechis-first-project.demos.CovidDeaths` dea
  JOIN `kelechis-first-project.demos.CovidVaccinations` Vac
  on dea.location = Vac.location
  and dea.date = Vac.date
  where dea.continent is not null
  )
  Select*, (RollingPeopleVaccinated/Population)*100
  from PopVsVac;
--Temp Table
DROP Table If exists demos.PercentPopulationVaccinated;
Create Table demos.PercentPopulationVaccinated
(
Continent string,
Location string,
Date datetime,
Population int,
RollingPeopleVaccinated int 
);
INSERT INTO demos.PercentPopulationVaccinated 
  Select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, 
  --(RollingPeopleVaccinated/population)*100
  from `kelechis-first-project.demos.CovidDeaths` dea
  JOIN `kelechis-first-project.demos.CovidVaccinations` Vac
  on dea.location = Vac.location
  and dea.date = Vac.date
  where dea.continent is not null
  order by 2,3;

-- Creating View for storage and later visualizations
  CREATE VIEW demos.PercentPopulationVaccinated as
  Select dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations, sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, 
  --(RollingPeopleVaccinated/population)*100
  from `kelechis-first-project.demos.CovidDeaths` dea
  JOIN `kelechis-first-project.demos.CovidVaccinations` Vac
  on dea.location = Vac.location
  and dea.date = Vac.date
  where dea.continent is not null;
  --order by 2,3