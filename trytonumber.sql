--権限付与
use role accountadmin;
grant usage on warehouse compute_wh to role sysadmin;
use role sysadmin;
use warehouse compute_wh;

--DB, SCHEMA, TABLE作成
create or replace database db_test;
create or replace schema schema_test;

--ダミーデータ作成
create or replace table test_table(start_int number);
insert into test_table(start_int)
select uniform(-10, 100, random()) as start_int
from table(generator(rowcount => 100));

table db_test.schema_test.test_table;


select * from db_test.schema_test.test_table
where start_int < 0;

create or replace table test_hihun
as 
select 
    start_int,
    CONCAT('-', CAST(START_INT AS VARCHAR)) AS START_INT_WITH_DASH
from db_test.schema_test.test_table
where start_int < 0;

table test_hihun;



select 
TRY_TO_NUMBER(
    REPLACE(
        REGEXP_REPLACE(CAST(start_int_with_dash AS VARCHAR), '^-', ''),
        ',',
        ''
    )
)
from test_hihun;


