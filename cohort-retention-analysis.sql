
-- Отримання текстової дати без часу для users
WITH users_step_1 AS (
    select user_id,
	signup_datetime,
		split_part (trim (signup_datetime), ' ', 1) as signup_date_without_time,
	promo_signup_flag
	from project.cohort_users_raw),

-- Заміна розділювача / на -
user_step_2 as (
	select 
	user_id,
	signup_datetime,
	replace (signup_date_without_time, '/', '-') as signup_date_without,
	promo_signup_flag
	FROM users_step_1),
		
-- заміна розділювача . на -	
user_step_3 as (
select 
	user_id,
	signup_datetime,
	replace (signup_date_without, '.', '-') as signup_date_unified,
	promo_signup_flag
	FROM user_step_2),	
	
-- Визначення довжини року (year_len), формату року: YYYY або YY
user_step_4 as (
select user_id,
	signup_datetime,
	promo_signup_flag,
	 signup_date_unified,
					length (split_part (signup_date_unified, '-',3)) as year_len
FROM user_step_3),

/* 	Перетворення текстової дати у тип date
 	Використання CASE для вибору формату (DD-MM-YYYY або DD-MM-YY)
	Створення очищеного поля signup_date_clear */

user_step_5 as (
select user_id,
	signup_datetime,
	promo_signup_flag,
case 
	when year_len = 4 then to_date (signup_date_unified,'dd-mm-yyyy')
when year_len = 2 then to_date (signup_date_unified,'dd-mm-yy')
end as signup_date_clear
from user_step_4),

-- покроковий CTE для events 

events_step_1 AS (
    select user_id,
		event_type, 	
		event_datetime,
			split_part (trim (event_datetime), ' ', 1) as event_date_without_time
	from project.cohort_events_raw),
events_step_2 as (
	select 
	user_id,
	event_type, 	
	event_datetime,
	replace (event_date_without_time, '/', '-') as event_date_without
	FROM events_step_1),
events_step_3 as (
select 
	user_id,
	event_type, 	
	event_datetime,
	replace (event_date_without, '.', '-') as event_date_unified
	FROM events_step_2),
events_step_4  as (
select 
	user_id,
	event_type, 	
	event_datetime,
	event_date_unified,
	length (split_part (event_date_unified, '-',3)) as year_len
FROM events_step_3 ),
events_step_5 as (
select 
	user_id,
	event_type, 	
	event_datetime,
	event_date_unified,
case 
	when year_len = 4 then to_date (event_date_unified,'dd-mm-yyyy')
		when year_len = 2 then to_date (event_date_unified,'dd-mm-yy')
			end as event_date_clear
from events_step_4),
 
-- Join: users + events

joined_users_events as (
 select 
	user_step_5.user_id as user_id,
	signup_date_clear,
	event_date_clear,
	promo_signup_flag,
	event_type
from user_step_5
join events_step_5 
	on user_step_5.user_id = events_step_5.user_id),
	
/*select * 
from  joined_users_events 
limit 15 */


--  Дата реєстрації на місяць когорти + дату події на місяць активності

cohort_data as (
select 
	user_id,
	signup_date_clear,
	event_date_clear,
	date_trunc ('month', signup_date_clear) as cohort_month,
	date_trunc ('month', event_date_clear) as activity_month,
	promo_signup_flag,
	event_type
from  joined_users_events),

-- select * from cohort_data  limit 10;

-- дістаю рік та місяць + різниця в місяцях (month_offset) для події та реєстрації, що буде вказувати на стаж користувача 

month_offset as (
select 
	user_id,
	signup_date_clear,
	event_date_clear,
	cohort_month, 
	extract ('year' from cohort_month) as cohort_year,
	extract ('month' from  cohort_month) as cohort_month_num,
	activity_month,
	extract ('year' from activity_month) as activity_year,
	extract ('month' from  activity_month) as activity_month_num,
	promo_signup_flag,
	event_type
from  cohort_data),

-- фільтрація where is not null  та активність 6 місяців 

filtered_data as (
	select 
		user_id,
		signup_date_clear,
		event_date_clear,
			(activity_year - cohort_year) * 12 + (activity_month_num - cohort_month_num) as month_offset,
		promo_signup_flag,
		event_type,
		cohort_month
	from month_offset
	where	 
			signup_date_clear is not null 
			and event_date_clear is not null 
			and event_type is not null 
			and event_type != 'test_event'
			and activity_month between '2025-01-01' and '2025-06-01'
			and (activity_year - cohort_year) * 12 + (activity_month_num - cohort_month_num)  >= 0)
	
-- фінальний селект 
		
select 
	promo_signup_flag,
	cohort_month,
	month_offset,
	count(distinct user_id) as users_total
from filtered_data
group by
    promo_signup_flag,
    cohort_month,
    month_offset 
order by promo_signup_flag, cohort_month,  month_offset 











