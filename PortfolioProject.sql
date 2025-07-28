
select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--chọn data sẽ dụng// nên xóa dòng này

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null

order by 1,2



-- xem xet tong so ca benh vs tong so ca tu vong / tinh ti le tu vong chiem bao nhieu percent
-- the hien kha nang tu vong neu ban bi nhiem covid o dat nuoc cua ban

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'vietnam'
where continent is not null
order by 1,2

-- xem xet tong so ca nhiem so voi tong dan so
-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null

order by 1,2


-- suy nghi theo huong khi nhin len tableau -> can gi
-- nhung quoc gia co ti le lay nhiem cao/ so tong so ca chet cao
-- Looking at country with Highest Infertion Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT ( gop chung chau luc - xem tong so nguoi chet cua cac chau luc)
Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is  null
group by location
order by TotalDeathCount desc




-- Showing Countries with Highest Death Count per population
Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count
Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
-- Tong so ca nhiem - ca chet  tren toan the gioi theo tung ngay
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int )) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location = 'vietnam'
where continent is not null
--Group By date
order by 1,2








-- join 2 bang (dea) - (vac) thong qua hai cot location va date
select *
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, location, date, population,new_vaccinations,  RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
From popvsvac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric , 
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated 