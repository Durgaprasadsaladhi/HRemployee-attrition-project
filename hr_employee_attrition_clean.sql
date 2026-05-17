create database HR_Employee_Attrition;
use HR_Employee_Attrition;
select * from hr_employee_attrition_clean;
alter table hr_employee_attrition_clean drop MyUnKnownColumn;

-- 1. Display the first 10 rows from the table.
select * from hr_employee_attrition_clean limit 10; 

-- 2. Find the total number of employees in the company.
select count(EmployeeNumber) as Total_number_of_employees from hr_employee_attrition_clean;

-- 3. List all unique departments.
select distinct(Department) from hr_employee_attrition_clean;

-- 4. Show how many employees have left the company and how many are still working.
select distinct(Attrition),count(Attrition) as Total_Employees,
case
when Attrition = 'Yes' then 'Left_The_Company' else 'Still_Working'
end as Employees_Status
from hr_employee_attrition_clean group by Attrition;

-- 5. Retrieve the list of employees who work overtime.
select*from hr_employee_attrition_clean where OverTime = "Yes"; 

-- 6. Find the average monthly income of all employees.
select avg(Monthly_Income) from hr_employee_attrition_clean;

-- 7. Identify employees whose number of companies worked is missing (NULL).
select * from hr_employee_attrition_clean where Num_of_Companies_Worked = 0;
select count(Num_of_Companies_Worked) from hr_employee_attrition_clean where Num_of_Companies_Worked = 0;

-- 8. Find the employee(s) with the maximum monthly income. 
select * from hr_employee_attrition_clean order by Monthly_Income desc;

-- 9. Count the number of employees by gender.
select Gender,count(Gender) as Total_employes from hr_employee_attrition_clean group by Gender;
  
-- 10. List all employees who have just joined (YearsAtCompany = 0). 
select * from hr_employee_attrition_clean where Years_At_Company = 0;
select count(Years_At_Company) from hr_employee_attrition_clean where Years_At_Company = 0;

-- 11. Calculate the attrition rate (%) by department.
select Department,count(*) as total_employees,
sum(case when Attrition = 'Yes' then 1 else 0 end) as left_the_company,
round(sum(case
	when Attrition = 'Yes' then 1 else 0 
	end)*100/count(*),2)as Attrition_rate
    from hr_employee_attrition_clean 
group by Department;
 
-- 12. List the top 10 employees with the highest total working years. 
select * from hr_employee_attrition_clean order by TotalWorkingYears desc limit 10; 

-- 13. Group employees into tenure categories (<1yr, 1–3yr, 4–6yr, 7+yr) and count employees in 
-- each.
select 
case
when TotalWorkingYears < 1 then '<1yr'
when TotalWorkingYears between 1 and 3 then '1–3yr'
when TotalWorkingYears between 4 and 6 then '4–6yr'
else '7+yr'
end as Tenure_category ,count(TotalWorkingYears) as count_of_employees_each_group
from hr_employee_attrition_clean group by Tenure_category order by Tenure_category asc;
 
-- 14. Find the average monthly income by job level and attrition status.
select JobLevel,round(avg(Monthly_Income),2) as avg_monthly_income from hr_employee_attrition_clean group by JobLevel order by JobLevel asc;
 
-- 15. Identify the top 5 job roles with the highest number of employees who left.
 select JobRole,count(Attrition) as number_of_employees_left_the_company from hr_employee_attrition_clean 
 where Attrition = 'Yes' group by JobRole order by count(Attrition) desc limit 5;
 
-- 16. List employees who left the company within their first year. 
select * from hr_employee_attrition_clean where Attrition = 'Yes' and Years_At_Company = 1;

-- 17. Determine the median monthly income of all employees.
 
-- 18. Calculate each employee’s approximate new monthly compensation after applying their 
-- salary hike percentage. 
select *,round(Monthly_Income+(Monthly_Income*Percent_of_Salary_Hike/100),2) as New_salary from hr_employee_attrition_clean;
select Monthly_Income,Percent_of_Salary_Hike,round(Monthly_Income+(Monthly_Income*Percent_of_Salary_Hike/100),2) as New_salary
from hr_employee_attrition_clean;  

-- 19. Count employees grouped by overtime status and attrition. 
select OverTime,Attrition,count(*) as employee_count from hr_employee_attrition_clean group by OverTime,Attrition;

-- 20. Display the top 10 employees who attended the most training sessions last year.
select * from hr_employee_attrition_clean
order by TrainingTimesLastYear desc limit 10;
 
-- 21. Rank employees by total working years (most experienced = rank 1).
select *,
rank() over(order by TotalWorkingYears desc) as rank_of_employees 
from hr_employee_attrition_clean; 
 
-- 22. For each department, find employees whose monthly income is in the top 25% of that 
-- department.
select Department,Monthly_Income,EmployeeNumber from hr_employee_attrition_clean where Monthly_Income >(Monthly_Income * 0.75) group by Department,Monthly_Income,EmployeeNumber;
select EmployeeNumber,Department,Monthly_Income from (select EmployeeNumber,Department,Monthly_Income,
percent_rank() over(partition by department order by Monthly_Income desc) as salary_group 
from hr_employee_attrition_clean) as percent_rk where salary_group <=0.25;

-- 23. Divide employees into 10 income deciles and find attrition rate for each decile. 
with income_decile as (select EmployeeNumber,Monthly_Income, Attrition, ntile(10) over(order by Monthly_Income) as income_decile
from hr_employee_attrition_clean)
select income_decile,count(*) as Total_application,
sum(case when Attrition = 'Yes' then 1 else 0 end) as attriton_count,
round(sum(case
when Attrition = 'Yes' then 1 else 0 
end)*count(*)/100,2) as attrition_rate from income_decile group by income_decile order by income_decile;

-- 24. Create a simple risk score based on tenure, performance, overtime, and work-life balance — 
-- and list the top 50 high-risk employees.
select EmployeeNumber,Department,JobRole,Years_At_Company,PerformanceRating,OverTime,WorkLifeBalance,
(case
when Years_At_Company <2 then 2 else 0
end+
case
when PerformanceRating = 3 then 1 else 0
end+
case 
when OverTime = 'Yes' then 3 else 0
end+
case
when WorkLifeBalance = 1 then 3
when WorkLifeBalance = 2 then 2
end) as risk_score from hr_employee_attrition_clean order by risk_score desc limit 50;

-- 25. Create a summary view showing, for each department and job level: total employees, 
-- number of leavers, attrition rate, and average monthly income.
select department,joblevel,count(*) as Total_employees,
sum(case
when attrition = 'Yes'then 1 else 0
end) as number_of_leaving_company,
round(sum(case
when attrition = 'Yes' then 1 else 0
end)*100.0/count(*),2) as attrition_rate,
round(avg(monthly_income),2) as avg_monthly_income from hr_employee_attrition_clean group by department,joblevel
order by department,joblevel;
