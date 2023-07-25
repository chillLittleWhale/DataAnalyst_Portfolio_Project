use  Portfolio_Project_Covid19
Go

select * from dbo.CovidDeaths
Order by 3,4     -- sắp xếp theo cột 3 và cột 4
Go
-- xem tỉ lệ nhiễm và tỉ lệ tử vong của 1 nước theo từng ngày
select location, date, total_cases, new_cases, total_deaths, population, 
	(total_cases / population)*100 as InfectionPercentage, (total_deaths / population)*100 as DeathPercentage
from dbo.CovidDeaths
where location like 'United States%'
Order by 1,2    
Go

-- xem tỉ lệ nhiễm và tử vong mới nhất của các nước
select location, population, max(total_cases) as 'total_cases' , max(cast(total_deaths as bigint)) as 'total_deaths',
	(max(total_cases) / population)*100 as InfectionPercentage, ( max(cast(total_deaths as bigint)) / population)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null              -- loại bỏ các dữ liệu không được xem là 1 nước duy nhất ( asia, americar, africa, ...)
Group by location, population
Order by DeathPercentage desc
Go

-- xem tỉ lệ nhiễm và tử vong mới nhất của các lục địa
select location, population, max(total_cases) as 'total_cases' , max(cast(total_deaths as bigint)) as 'total_deaths',
	(max(total_cases) / population)*100 as InfectionPercentage, ( max(cast(total_deaths as bigint)) / population)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is null            
Group by location, population
Order by population desc
Go

-- tổng số ca nhiễm và tử vong trên toàn thế giới theo từng ngày
select date, sum(new_cases) as 'total_cases' , sum(cast(new_deaths as bigint)) as 'total_deaths',
	 (sum(cast(new_deaths as bigint)) / sum(new_cases)) * 100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null            
Group by date
Order by date asc 
Go

-- dung Partition de tinh tong vacination theo tung ngya o tung quoc gia
with cte_vac(continent, location, date, population, new_vaccinations, total_vacination)
as(
Select vac.continent, vac.location, vac.date, dea.population, vac.new_vaccinations, 
	sum(convert(bigint,vac.new_vaccinations )) over (Partition by vac.location order by vac.location, vac.date) as total_vacination
from dbo.CovidVaccinations vac
inner join dbo.CovidDeaths dea
on vac.location = dea.location And vac.date = dea.date
where dea.continent is not null
--Order by vac.location , vac.date 
)
select *, (total_vacination / population)*100 as vacinnationPercentage
from cte_vac
Order by location , date 



-- tạo view với dữ liệu trên
Create view PercentPopulationVaccinated as
Select vac.continent, vac.location, vac.date, dea.population, vac.new_vaccinations, 
	sum(convert(bigint,vac.new_vaccinations )) over (Partition by vac.location order by vac.location, vac.date) as total_vacination
from dbo.CovidVaccinations vac
inner join dbo.CovidDeaths dea
on vac.location = dea.location And vac.date = dea.date
where dea.continent is not null

