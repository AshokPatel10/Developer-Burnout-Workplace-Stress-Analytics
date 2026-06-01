SELECT * 
FROM developer_burnout_data 
LIMIT 10;

--------------🔹 Basic High Layoff Risk Distribution --------------
-- Q1. How many employees are classified as high layoff risk in each experience group?
SELECT experience_group,
		COUNT(developer_id) AS no_of_employees
FROM developer_burnout_data
WHERE high_layoff_risk = 'Yes'
GROUP BY experience_group
ORDER BY no_of_employees DESC;
-- Q2. What percentage of high layoff risk employees belong to each experience group?
SELECT experience_group,
		COUNT(*) AS high_risk_empployees,
		ROUND(
		COUNT(*)*100.0/(SELECT COUNT(*) FROM developer_burnout_data 
		WHERE high_layoff_risk = 'Yes'),2) AS percentage_of_high_risk_emp
FROM developer_burnout_data
WHERE high_layoff_risk = 'Yes'
GROUP BY experience_group
ORDER BY percentage_of_high_risk_emp DESC;
--Q3. Which experience group has the highest number of high layoff risk employees?
SELECT experience_group,
		COUNT(*) AS high_risk_emp
FROM developer_burnout_data
WHERE high_layoff_risk = 'Yes'
GROUP BY experience_group
ORDER BY high_risk_emp DESC
LIMIT 1;
--Q4. Which experience group has the lowest number of high layoff risk employees?
SELECT experience_group,
		COUNT(*) AS high_risk_emp
FROM developer_burnout_data
WHERE high_layoff_risk = 'Yes'
GROUP BY experience_group
ORDER BY high_risk_emp ASC
LIMIT 1;

--------------🔹 Layoff Risk vs Experience --------------
SELECT * 
FROM developer_burnout_data 
LIMIT 10;
--Q5. How does high layoff risk vary across experience groups?
--Q6. Do freshers face higher layoff risk than senior employees?
SELECT experience_group,
		COUNT(*) AS total_employees,
		SUM(CASE WHEN high_layoff_risk = 'Yes' THEN 1 ELSE 0 END) AS High_risk,
		ROUND(100*SUM(CASE WHEN high_layoff_risk = 'Yes' THEN 1 ELSE 0 END)/
		COUNT(*)::NUMERIC,2)
		AS Percentage
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY Percentage DESC;
--Q7. Which experience group has the highest average layoff anxiety score?
SELECT experience_group,
		ROUND(AVG(layoff_anxiety_score)::NUMERIC,2) AS avg_layoff_anxiety_score
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY avg_layoff_anxiety_score DESC
LIMIT 1;
--Q8. Which experience group has the highest job security confidence?
WITH confidence_scores AS (
    SELECT experience_group,
           ROUND(AVG(job_security_confidence)::NUMERIC, 2) AS avg_security_confidence
    FROM developer_burnout_data
    GROUP BY experience_group
)
SELECT *
FROM confidence_scores
WHERE avg_security_confidence = (
    SELECT MAX(avg_security_confidence)
    FROM confidence_scores
);
 
--------------🔹 Burnout vs Experience --------------
SELECT * 
FROM developer_burnout_data 
LIMIT 10;
--Q9. How is burnout risk distributed across experience groups?
SELECT experience_group, burnout_risk_category,
		COUNT(*) AS no_of_emp
FROM developer_burnout_data
GROUP BY experience_group, burnout_risk_category
ORDER BY experience_group,no_of_emp DESC;
--Q10. Which experience group has the highest average burnout score?
WITH CTE AS (
		SELECT experience_group,
		ROUND(AVG(burnout_score)::NUMERIC,2) AS avg_burnout_score
		FROM developer_burnout_data
		GROUP BY experience_group
)
SELECT * 
FROM CTE
WHERE avg_burnout_score = (SELECT MAX(avg_burnout_score) FROM CTE);
--Q11. How does work-life balance differ across experience groups?
SELECT experience_group,
		ROUND(AVG(work_life_balance_Rating)::NUMERIC,2) AS avg_work_life_rating
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY avg_work_life_rating DESC;

--------------🔹 Company-Level Analysis --------------
SELECT * 
FROM developer_burnout_data 
LIMIT 10;
--Q12. Which company type has the highest percentage of high layoff risk employees?
SELECT company_type,
		COUNT(*) AS total_emp,
		SUM(CASE WHEN high_layoff_risk = 'Yes' THEN 1 ELSE 0 END) AS high_risk_emp,
		ROUND(100*SUM(CASE WHEN high_layoff_risk = 'Yes' THEN 1 ELSE 0 END)/
		COUNT(*)::NUMERIC,2) AS layoff_risk_rate
FROM developer_burnout_data
GROUP BY company_type
ORDER BY layoff_risk_rate DESC;
--Q13. How does burnout risk vary between startups and Consulting?
SELECT company_type,
			COUNT(*) AS total_emp,
			SUM(CASE WHEN burnout_risk_category = 'High' THEN 1 ELSE 0 END) 
			AS high_burnout_emp,
			ROUND(100*SUM(CASE WHEN burnout_risk_category = 'High' THEN 1 ELSE 0 END)/
			COUNT(*)::NUMERIC,2) AS high_burnout_percentage
FROM developer_burnout_data
WHERE company_type IN ('Startup','Consulting')
GROUP BY company_type
ORDER BY high_burnout_percentage DESC;
--Q14. Which company size reports the highest average stress level?
SELECT company_size,
		ROUND(AVG(stress_level)::NUMERIC,2) AS avg_stress_level
FROM developer_burnout_data
GROUP BY company_size
ORDER BY avg_stress_level DESC;
--Q15. Do employees in Product-based companies show different burnout patterns 
-- than those in Service-based companies?
SELECT company_type,
       ROUND(AVG(burnout_score)::NUMERIC, 2) AS avg_burnout_score
FROM developer_burnout_data
WHERE company_type IN ('Product-based', 'Service-based')
GROUP BY company_type
ORDER BY avg_burnout_score DESC;

--------------🔹 Career Growth & Job Switching --------------
SELECT * 
FROM developer_burnout_data 
LIMIT 10;
--Q16. Which experience group is most likely to switch jobs?
SELECT experience_group,
		SUM(CASE WHEN likely_to_switch_job = 'Yes' THEN 1 ELSE 0 END) 
		AS no_of_likely_to_switch_jobs
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY no_of_likely_to_switch_jobs DESC;
--Q17. Does burnout increase the likelihood of switching jobs?
SELECT burnout_risk_category,
		COUNT(*) AS total_employee,
		SUM(CASE WHEN likely_to_switch_job = 'Yes' THEN 1 ELSE 0 END) 
		AS switch_job_employees,
		ROUND(100*SUM(CASE WHEN likely_to_switch_job = 'Yes' THEN 1 ELSE 0 END)/
		COUNT(*)::NUMERIC,2) AS switch_job_percentage
FROM developer_burnout_data
GROUP BY burnout_risk_category
ORDER BY switch_job_percentage DESC;
--Q18. How do promotions affect burnout and layoff risk?
SELECT promotion_last_2_years,
		COUNT(*) AS total_employee,
		ROUND(AVG(burnout_score)::NUMERIC,2) AS avg_burnout_score,
		ROUND(100*SUM(CASE WHEN high_layoff_risk = 'Yes' THEN 1 ELSE 0 END)/
		COUNT(*)::NUMERIC,2) AS high_layoff_risk_percentage
FROM developer_burnout_data
GROUP BY promotion_last_2_years;
--Q19. Are employees with more job switches more likely to have high layoff risk?
SELECT number_of_switches,
		COUNT(*) AS total_employee,
		ROUND(100*SUM(CASE WHEN high_layoff_risk = 'Yes' THEN 1 ELSE 0 END)/
		COUNT(*)::NUMERIC,2) AS high_layoff_risk_percentage
FROM developer_burnout_data
GROUP BY number_of_switches
ORDER BY high_layoff_risk_percentage DESC;

--------------🔹 Salary & Financial Security Analysis --------------
SELECT * 
FROM developer_burnout_data 
LIMIT 10;
--Q20. How does salary vary across experience groups?
SELECT experience_group,
		MIN(salary_lpa) AS min_salary,
		ROUND(AVG(salary_lpa)::NUMERIC,2) AS avg_salary,
		MAX(salary_lpa) AS max_salary
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY avg_salary DESC;
--Q21. Do higher-paid employees report lower job security confidence?
SELECT
    experience_group,
    ROUND(AVG(salary_lpa)::NUMERIC, 2) AS avg_salary,
    ROUND(AVG(job_security_confidence)::NUMERIC, 2) AS avg_job_security_confidence
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY avg_salary DESC;
--Q22. What is the average emergency savings duration across experience groups?
SELECT experience_group,
		ROUND(AVG(emergency_savings_months)::NUMERIC,2) AS avg_savings_months
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY avg_savings_months DESC;
--Q23. Does financial preparedness reduce layoff anxiety?
SELECT
	CASE 
		WHEN emergency_savings_months<=3 THEN '1-3 months'
		WHEN emergency_savings_months<=6 THEN '4-6 months'
		WHEN emergency_savings_months<=12 THEN '7-12 months'
		WHEN emergency_savings_months<=24 THEN '13-24 months'
		ELSE '25-36 months'
		END AS savings_group,
		COUNT(*) AS total_employees,
		ROUND(AVG(layoff_anxiety_score)::NUMERIC,2) AS avg_layoff_anxiety
FROM developer_burnout_data
GROUP BY savings_group
ORDER BY avg_layoff_anxiety DESC;

--------------🔹 Stress & Mental Health Analysis --------------
SELECT * 
FROM developer_burnout_data 
LIMIT 10;
--Q24. Which experience group has the highest stress level?
SELECT experience_group,
		ROUND(AVG(stress_level)::NUMERIC,2) AS avg_stress_level
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY avg_stress_level DESC;
--Q25. How does sleep duration affect burnout score?
SELECT CASE
		WHEN sleep_hours < 5 THEN 'less than 5 hours'
		WHEN sleep_hours < 7 THEN '5-7 hours'
		ELSE '7-10 hours'
		END AS sleep_groups,
		COUNT(*) AS total_employees,
		ROUND(AVG(burnout_score)::NUMERIC,2) AS avg_burnout_score
FROM developer_burnout_data
GROUP BY sleep_groups
ORDER BY avg_burnout_score DESC;
--Q26. Does therapy or counseling correlate with lower anxiety levels?
SELECT therapy_or_counseling,
		ROUND(AVG(anxiety_score)::NUMERIC,2) AS avg_anxiety_score
FROM developer_burnout_data
GROUP BY therapy_or_counseling
ORDER BY avg_anxiety_score DESC;
--Q27. How does physical activity impact mental exhaustion?
SELECT mentally_exhausted,
		ROUND(AVG(physical_activity_days_per_week)::NUMERIC,2) 
		AS avg_physical_activity_weekly
FROM developer_burnout_data
GROUP BY mentally_exhausted
ORDER BY avg_physical_activity_weekly DESC;

--------------🔹 AI & Future Career Concerns --------------
SELECT * 
FROM developer_burnout_data 
LIMIT 10;
--Q28. Which experience group has the higher AI replacement fear score?
SELECT experience_group,
		COUNT(*) AS total_employees,
		ROUND(AVG(ai_tools_usage_hours_per_week)::NUMERIC,2) AS avg_ai_usage_time,
		ROUND(AVG(ai_replacement_fear_score)::NUMERIC,2) AS avg_ai_fear_score
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY avg_ai_fear_score DESC;
--Q29. Does AI replacement fear influence job search activity?
SELECT linkedin_job_search_activity,
		ROUND(AVG(ai_replacement_fear_score)::NUMERIC,2) AS avg_ai_fear_score
FROM developer_burnout_data
GROUP BY linkedin_job_search_activity
ORDER BY avg_ai_fear_score DESC; 
--Q30. How does AI fear affect job security confidence?
SELECT
		CASE
			WHEN ai_replacement_fear_score <=3 THEN 'low AI fear'
			WHEN ai_replacement_fear_score <=7 THEN 'Medium AI fear'
			ELSE 'High AI fear'
			END AS Ai_fear_group,
		ROUND(AVG(job_security_confidence)::NUMERIC,2) AS avg_job_security_confidence
FROM developer_burnout_data
GROUP BY Ai_fear_group
ORDER BY avg_job_security_confidence DESC;
--Q31. Are employees with higher AI fear more likely to switch jobs?
SELECT likely_to_switch_job,
        COUNT(*) AS total_employees,
		ROUND(AVG(ai_replacement_fear_score)::NUMERIC,2) AS avg_ai_fear_score
FROM developer_burnout_data
GROUP BY likely_to_switch_job
ORDER BY avg_ai_fear_score DESC;

--------------🔹 Risk & Predictive Insights --------------
SELECT * 
FROM developer_burnout_data 
LIMIT 10;
--Q32. Can burnout score, anxiety score, and job security confidence 
---predict high layoff risk?
SELECT high_layoff_risk,
       ROUND(AVG(burnout_score)::NUMERIC, 2) AS avg_burnout_score,
       ROUND(AVG(anxiety_score)::NUMERIC, 2) AS avg_anxiety_score,
       ROUND(AVG(job_security_confidence)::NUMERIC, 2) AS avg_job_security_confidence
FROM developer_burnout_data
GROUP BY high_layoff_risk;

--------------🔥 Advanced Analytical Questions --------------
SELECT * 
FROM developer_burnout_data 
LIMIT 10;
--Q33. Which experience group appears most resilient based on burnout, stress, 
---and job security metrics?
SELECT
    experience_group,
    ROUND(AVG(burnout_score)::NUMERIC, 2) AS avg_burnout,
    ROUND(AVG(stress_level)::NUMERIC, 2) AS avg_stress,
    ROUND(AVG(job_security_confidence)::NUMERIC, 2) AS avg_job_security
FROM developer_burnout_data
GROUP BY experience_group
ORDER BY avg_burnout ASC,
		avg_stress ASC,
		avg_job_security DESC;
--Q34. Layoff_risk by location city
SELECT city,
		ROUND(AVG(layoff_anxiety_score)::NUMERIC,2) AS avg_layoff_anxiety_score,
		ROUND(AVG(job_security_confidence)::NUMERIC,2) AS avg_job_security_confidence
FROM developer_burnout_data
GROUP BY city
ORDER BY avg_layoff_anxiety_score DESC,avg_job_security_confidence DESC;

