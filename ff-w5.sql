--権限付与
use role accountadmin;
grant usage on warehouse compute_wh to role sysadmin;
use role sysadmin;
use warehouse compute_wh;

--DB, SCHEMA, TABLE作成
create or replace database db_week5;
create or replace schema schema_week5;

--ダミーデータ作成
create or replace table table_week5(start_int number);
insert into table_week5(start_int)
select uniform(0, 100, random()) as start_int
from table(generator(rowcount => 100));

table db_week5.schema_week5.table_week5;

--UDF作成
--Python
create or replace function x3_py(i number)
returns number
language python
runtime_version = '3.12'
handler = 'timesthree_py'
as
$$
def timesthree_py(i):
    return i*3
$$;

-- 使ってみる
select start_int, x3_py(start_int) as start_int_x3
from table_week5
order by start_int;


--BMI
create or replace table table_week5_bmi (height number , weight number);
insert into table_week5_bmi (height, weight)
select
    uniform(150, 190, random()) as height,
    uniform(50, 90, random()) as weight
from table(generator(rowcount => 100));

table table_week5_bmi;

--UDF作成
--python
create or replace function calc_bmi_python(height number, weight number)
returns number
language python
runtime_version = '3.12'
handler = 'calc_bmi'
as
$$
def calc_bmi(height, weight):
    return weight / ( (height/100 ) ** 2)
$$
;

--使ってみよう
select height, weight, calc_bmi_python(height, weight) as BMI
from table_week5_bmi;


--sql
create or replace function calc_bmi_sql(height number, weight number)
returns number
language sql
as
$$
weight / ( (height / 100) * (height / 100))
$$;

--使ってみよう
select height, weight, calc_bmi_sql(height, weight) as BMI from table_week5_bmi;
