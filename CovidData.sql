-- covid deaths queries

Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 3,4


-- Selecting data that i will be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not NULL
order by 1,2


-- Looking at Total cases vs Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%ghana%'
and continent is not NULL
order by 1,2


-- Looking at the Total cases vs the Population
-- Shows percentage of population that had Covid

Select location, date, population, total_cases,  (total_cases/population)* 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%ghana%' and continent is not NULL
order by 1,2


-- Looking at Countries with Highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))* 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Counts per population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENTS

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is NULL
Group by location
order by TotalDeathCount desc


-- Showing the Continents with the highest  count per population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not NULL
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as NewCasesPerDay, SUM(cast(new_deaths as int)) as NewDeathsPerDay, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not NULL
Group by date
order by 1,2

-- total cases and total deaths
Select SUM(new_cases) as NewCasesPerDay, SUM(cast(new_deaths as int)) as NewDeathsPerDay, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not NULL
order by 1,2


-- including COVID VACCINATIONS
Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--joining the two tables

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not Null
order by 2,3


-- USING A CETs
WITH PopVSVac (Continent, Location, Date, Population,New_Vaccination, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not Null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100 as PercentageVaccinated
From PopVSVac


-- Using TEMP TABLE for the above as well
DROP TABLE if exists #PercentPopulationVaccinated

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not Null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100 as PercentageVaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not Null

Select * 
From PercentPopulationVaccinated