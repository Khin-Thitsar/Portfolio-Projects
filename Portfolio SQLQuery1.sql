select * from [Portfolio Project]..['covid-death$']
order by 3,4
 
select * from [Portfolio Project]..['covid-vaccination$']

 --Total cases vs. Total Death
 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_Percentage
 from [Portfolio Project]..['covid-death$']
 where location like '%myanmar%'
 order by 1,2

 --population vs total case
 select location, date, population, total_cases, (total_cases/population)*100 as Infected_Percentage
 from [Portfolio Project]..['covid-death$']
 where location like '%myanmar%'
 order by 1,2

 --Highest infected countries
 Select location, population, MAX(total_cases)as highest_case_count, 
 Max(total_cases/Population)* 100 as Infected_Percentage
 From [Portfolio Project]..['covid-death$']
 group by location, population
 order by Infected_Percentage desc

 --Highest death counts countries
 Select location, MAX(cast (total_deaths as int)) as highest_death_counts
 From [Portfolio Project]..['covid-death$']
 where continent is not null
 group by location
 order by highest_death_counts desc

 -- Using Continent
Select continent, MAX(cast (total_deaths as int)) as highest_death_counts
 From [Portfolio Project]..['covid-death$']
 where continent is not null
 group by continent
 order by highest_death_counts desc

 -- Globel Number
select date, SUM( new_cases) as Total_cases, sum(cast (new_deaths as int))as Total_deaths,
sum(cast (new_deaths as int))/sum(new_cases)*100 as death_Percentage
 from [Portfolio Project]..['covid-death$']
 Where continent is not null
 group by date
 order by 1,2

--total world number
select SUM( new_cases) as Total_cases, sum(cast (new_deaths as int))as Total_deaths,
sum(cast (new_deaths as int))/sum(new_cases)*100 as death_Percentage
 from [Portfolio Project]..['covid-death$']
 order by 1,2

 --Join two tables
 select * from [Portfolio Project]..['covid-death$'] dea
 Join [Portfolio Project]..['covid-vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 order by 3,4

 --total population vs. vaccination
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 from[Portfolio Project]..['covid-death$'] dea
 Join [Portfolio Project]..['covid-vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

--Rolling Count
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_number
 from [Portfolio Project]..['covid-death$'] dea
 Join [Portfolio Project]..['covid-vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

--use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, rolling_number)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_number
 from [Portfolio Project]..['covid-death$'] dea
 Join [Portfolio Project]..['covid-vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 )
 --Select * from PopVsVac

  Select *, (rolling_number/population)*100 as rolling_percentage from PopVsVac

  --temp table

  Drop table if exists Percentage_population_vaccinated
  Create Table Percentage_population_vaccinated
  (continent nvarchar (225),
  location nvarchar (225),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  rolling_number numeric)

 insert into Percentage_population_vaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_number
 from [Portfolio Project]..['covid-death$'] dea
 Join [Portfolio Project]..['covid-vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null

  Select * from Percentage_population_vaccinated
  Select *, (rolling_number/population)*100 as vaccinated_percentage from Percentage_population_vaccinated

--Creating View to store data for later visulation

Create View Percentage_population_vaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_number
 from [Portfolio Project]..['covid-death$'] dea
 Join [Portfolio Project]..['covid-vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3

