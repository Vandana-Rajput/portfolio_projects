use portfolio_project;

-- Link to dataset https://ourworldindata.org/covid-deaths
-- Importing CSV file to MySQL workbench
# - /*load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads/covidvaccinations.csv' into table
# -  covidvaccinations FIELDS terminated by ','  enclosed by '"' lines terminated by '\r\n' 
# - ignore 1 lines SET date = DATE_FORMAT(date,'%Y-%m-%d');

# - load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads/coviddeaths.csv' into table
# - coviddeaths FIELDS terminated by ','  enclosed by '"' lines terminated by '\r\n' 
# - ignore 1 lines SET date = DATE_FORMAT(date,'%Y-%m-%d');


-- Total cases vs Total death(likelihood of dying if you catch corona virus)

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    total_deaths * 100 / total_cases AS deathrate_of_infected
FROM
    coviddeaths
WHERE
    location = 'India'
ORDER BY 1 , 2;

-- Total cases vs population(likelihood of getting infected)
-- by date and location
select date, location, population, total_cases, total_cases*100/population as infection_rate
from coviddeaths;


-- Countries with highest infection rate
select location, population, max(total_cases) total_cases, max(total_cases)*100/population as max_infection_rate  
from coviddeaths 
where location <> continent 
group by 1 order by 4 desc;


-- Countries with highest death count
select location, max(total_deaths) as total_deathcount 
from coviddeaths 
where location <> continent 
group by 1 order by 2 desc;


-- Continent with highest death count
select continent, max(total_deaths) as total_deathcount 
from coviddeaths  
where location = continent 
and continent not in  ("International")
group by 1 order by 2 desc;

-- Continent and location with highest death count
select continent, location , max(total_deaths) total_deathcount 
from coviddeaths  
where location <> continent
group by 1,2 order by 1;

-- Global number
select date, sum(new_cases) Worldwide_total_cases, sum(new_deaths) Worldwide_total_deaths,  
sum(new_deaths)*100/sum(new_cases) as deathrate_of_infected 
from coviddeaths 
group by 1 order by 1;

-- Total population vs vaccination

drop table if exists RollingPeopleVaccinated;
create table RollingPeopleVaccinated (
continent varchar(40),
location varchar(40),
date date,
population bigint,
new_vaccinations int,
RollingPeopleVaccinated bigint
);

insert into RollingPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) RollingPeopleVaccinated
from covidvaccinations vac 
join coviddeaths dea 
on dea.location = vac.location and dea.date = vac.date
where dea.continent <>  dea.location 
group by 1,2, 3 order by 1,2,3 ;

select R.*, RollingPeopleVaccinated*100/population as pct_people_vaccinated 
from RollingPeopleVaccinated R 
group by 1,2,3 
order by 2,3;

-- by Temp table 
create temporary table RollingPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) RollingPeopleVaccinated
from covidvaccinations vac 
join coviddeaths dea 
on dea.location = vac.location and dea.date = vac.date
where dea.continent <>  dea.location 
group by 1,2, 3 order by 1,2,3 ;

select R.*, RollingPeopleVaccinated*100/population as pct_people_vaccinated 
from RollingPeopleVaccinated R 
group by 1,2,3 
order by 2,3;


-- creating views(for visualization)
create or replace view v_RollingPeopleVaccinated As
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date ) RollingPeopleVaccinated
from covidvaccinations vac 
join coviddeaths dea 
on dea.location = vac.location and dea.date = vac.date
where dea.continent <>  dea.location group by 1,2, 3 order by 1,2,3 ;


select VR.*, RollingPeopleVaccinated*100/population as pct_people_vaccinated 
from v_RollingPeopleVaccinated VR 
group by 1,2,3 
order by 2,3;
