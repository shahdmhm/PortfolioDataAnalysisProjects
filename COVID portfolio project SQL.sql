--select * 
--from PortfolioProject..CovidDeaths
--order by 3,4


--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Data i am going to use 

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total cases vs total Deaths
-- Shows the liklihood of dying if you contract covid in Saudi Arabia

select Location, date, total_cases,total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Saudi Arabia' 
--like '%Saudi%'
order by 1,2

-- Looking for total cases vs Population
--Shows the percentage of population got covid

select Location, date,population, total_cases, (total_cases/ population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'Saudi Arabia' 
order by 1,2

-- Looking at countries with highest infication rate compared to Population

select Location,population, MAX(total_cases) AS highestInficationCount, max((total_cases/ population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'Saudi Arabia' 
group by Location, population
order by PercentPopulationInfected DESC

-- Showing countries with highset death count per population

select Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Saudi Arabia' 
where continent is not null
group by Location
order by TotalDeathCount DESC

-- Showing continents with the highest death count per population

select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Saudi Arabia' 
where continent is not null
group by continent
order by TotalDeathCount DESC

--  Global Numbers

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location = 'Saudi Arabia' 
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinations

select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject .. CovidDeaths as dea
join PortfolioProject .. CovidVaccinations as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) as
(
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject .. CovidDeaths as dea
join PortfolioProject .. CovidVaccinations as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--creating view to store data for later visulization 

--Create View PercentPopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
