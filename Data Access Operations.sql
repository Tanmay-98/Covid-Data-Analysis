Select *
from [Covid Data]..CovidDeaths
order by 3,4

Select *
from [Covid Data]..CovidVaccinations
order by 3,4

-----------------------------------------------------------
-- Select Data 
Select location, date, total_cases, new_cases, total_deaths, population
from [Covid Data]..CovidDeaths
order by 1,2

-----------------------------------------------------------
-- toal cases vs total deaths

Select location, date, total_cases, total_deaths
from [Covid Data]..CovidDeaths
order by 1,2

-----------------------------------------------------------
-- shows likelihood of dying if you contact covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid Data]..CovidDeaths
where location like '%canada%'
order by 1,2


-----------------------------------------------------------
-- Total Cases vs Population
-- percentage of population got covid

Select location, date, total_cases, population, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid Data]..CovidDeaths
--where location like '%canada%'
order by 1,2

 ----------------------------------------------------------
 -- Countries with Highest Infection Rate compared to Population

 select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_deaths/total_cases))*100 as PercentPopulationInfected
 from [Covid Data]..CovidDeaths
 Group by location, population
 order by PercentPopulationInfected desc

 ----------------------------------------------------------
 -- Countires with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
 from [Covid Data]..CovidDeaths
 where continent is not null
 Group by location
 order by TotalDeathCount desc
 
 ----------------------------------------------------------
 -- Sort by Continent

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from [Covid Data]..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

 ----------------------------------------------------------
 -- Global Numbers

-- Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Covid Data]..CovidDeaths
where continent is not null
--group by date
order by 1,2


 ----------------------------------------------------------
 -- Total Population vs Vaccination

with PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
from [Covid Data]..CovidDeaths dea
join [Covid Data]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
from [Covid Data]..CovidDeaths dea
join [Covid Data]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


