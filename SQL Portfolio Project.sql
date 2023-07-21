select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--selecting main columns we will be concentrating on for CovidDeaths

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null


--ordering so that information is displayed in ascending order based on location and date
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

---looking at death percentage as covid cases increase
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Column is nvachar data type, converting to float for calculation

ALTER TABLE CovidDeaths 
ALTER COLUMN
	total_cases float

	ALTER TABLE CovidDeaths 
ALTER COLUMN
	total_deaths float
	

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

---Script to see death rate percentage by countries
select location, population, max(total_cases) as HighInfectionCount, max(total_deaths) as HighDeathCount,
(max(total_deaths)/max(total_cases))* 100 as PercentPopulationInfected
---(max(total_cases)/max(total_deaths)) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%Mauri%'
group by location, population
order by 1,2

---script to see contries with the highest death rate in percentage at the top
select location, population, max(total_cases) as HighInfectionCount, max(total_deaths) as HighDeathCount,
(max(total_deaths)/max(total_cases))* 100 as PercentPopulationInfected
---(max(total_cases)/max(total_deaths)) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%Mauri%'
group by location, population
order by PercentPopulationInfected desc

---script to compare percentage infection rate to actual population by location/country
select location, population, max(total_cases) as HighInfectionCount, 
(max(total_cases)/population) * 100 as populationinfectedpercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%Mauri%'
group by location, population
order by 1,2

---VIEWING UNITED STATES DATA
select location, date, population, total_cases, 
(total_cases/population) * 100 as populationinfectedpercentage
from PortfolioProject..CovidDeaths
where location like 'United States'
and continent is not null
---group by location, population
order by 1,2 desc


select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'United States'
where continent is not null
group by location
order by TotalDeathCount desc

---looking at data by continent
select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'United States'
where continent is not null
group by continent
order by TotalDeathCount desc


---GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths)/sum(new_cases)*100 as percentageexpression
from CovidDeaths
where continent is not null
--and new_cases is not null 
--and new_deaths is not null
group by date
order by date


--RAN COMMAND BELOW BECAUSE OF NULL ERROR MESSAGE IN OUTPUT FOR GLOBAL NUMBERS
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF

---viwwing details in CovidVacination table

select * from CovidVaccinations

---joining CovidDeaths and CovidVaccination tables

select * from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

---looking at total world population vs total vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
and dea.continent is not null
order by 2,3

---rolling count on new_vacinations to monitor vacination progression
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as ProgressiveVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
and dea.continent is not null
---and dea.location = 'United States'
order by 2,3

---USING COMMON TABLE EXPRESSIONS
With PopulationVacinated(continent, location, date, population, new_vaccinations, ProgressiveVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as ProgressiveVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
and dea.continent is not null
---and dea.location = 'United States'
---order by 2,3
)

select * ,(ProgressiveVaccination/population)*100
from PopulationVacinated



---USING A TEMPORARY TABLE
Create table PopulationVacinatedTemp
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
ProgressiveVaccination numeric
)
INSERT INTO PopulationVacinatedTemp

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as ProgressiveVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
and dea.continent is not null
---and dea.location = 'United States'
---order by 2,3

select * ,(ProgressiveVaccination/population)*100
from PopulationVacinatedTemp


---CREATING A VIEW FOR VISUALIZATION LATER ON
Create view PopulationVacinatedView as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as ProgressiveVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
and dea.continent is not null

select * from PopulationVacinatedView