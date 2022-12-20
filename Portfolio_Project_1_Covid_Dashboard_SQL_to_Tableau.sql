select *
from Portfolio_Project_Num1.dbo.Covid_Deaths
where continent is not null
order by 3, 4;

--select *
--from Portfolio_Project_Num1.dbo.Covid_Vacc 
--order by 3,4; 

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project_Num1.dbo.Covid_Deaths
where continent is not null
order by 1,2;


-- Total Cases Versus Total Deaths in the United States 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percantage 
from Portfolio_Project_Num1.dbo.Covid_Deaths
where location like '%united states%'and continent is not null
order by 1,2;

-- Percentage of Popultaion with Covid-19 in the United States (Tableau Table #4)
select location, date, total_cases, population, (total_cases/population)*100 as Total_Infected_Population 
from Portfolio_Project_Num1.dbo.Covid_Deaths
--where location like '%united states%' and continent is not null
order by 1,2;

-- Countries with Highest Infection Rate compared to Population (Tableau Table #3)
select location, population, MAX(total_cases) as Highest_Infection_Count, Max((total_cases/population)*100) as PercentagePopulationInfected
from Portfolio_Project_Num1.dbo.Covid_Deaths
where continent is not null
Group by population, location
order by PercentagePopulationInfected desc;

--Countries with the Highest Death Count per population 
select location, MAX(cast(total_deaths as int))  as Total_Death_Count
from Portfolio_Project_Num1.dbo.Covid_Deaths
where continent is not null
Group by location
order by Total_Death_Count desc;


--Continent with the Highest Death Count per Population (Tableau Worthy #2)
select location, MAX(cast(total_deaths as int))  as Total_Death_Count
from Portfolio_Project_Num1.dbo.Covid_Deaths
where continent is not null
Group by location 
order by Total_Death_Count desc;

--Global Numbers (Tableau Worthy #1)  
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, (Sum(cast(new_deaths as int))/Sum(new_cases))*100 as Death_Percantage 
from Portfolio_Project_Num1.dbo.Covid_Deaths
--where location like '%united states%'and continent is not null
where continent is not null 
--group by date 
order by 1,2;


--Join Query Based on Location and Date 

select *  
from Portfolio_Project_Num1.dbo.Covid_Deaths dea 
join Portfolio_Project_Num1.dbo.Covid_Vacc vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total Population Versus Vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_Population_Vaccinated 
from Portfolio_Project_Num1.dbo.Covid_Deaths dea 
join Portfolio_Project_Num1.dbo.Covid_Vacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- Options 
-- CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_Population_Vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_Population_Vaccinated 
from Portfolio_Project_Num1.dbo.Covid_Deaths dea 
join Portfolio_Project_Num1.dbo.Covid_Vacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * , (Rolling_Population_Vaccinated/population)*100 
from PopvsVac


-- Temp Tables 

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portfolio_Project_Num1.dbo.Covid_Deaths dea 
join Portfolio_Project_Num1.dbo.Covid_Vacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select * , (RollingPeopleVaccinated/population)*100 
from #PercentagePopulationVaccinated


-- Use "Continent with the Highest Death Count per population" to create views 

--Creeating View to store data later for visualizations 

Drop view if exists PercentagePopulationVaccinated
Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from Portfolio_Project_Num1.dbo.Covid_Deaths dea 
join Portfolio_Project_Num1.dbo.Covid_Vacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
