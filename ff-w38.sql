--権限
use role sysadmin;
use warehouse compute_wh;

--データベース作成
create or replace database db_week38;
use database db_week38;
create or replace schema schema_week38;
use schema schema_week38;

-- １つ目のテーブル作成
create or replace table employees (
    id int,
    name varchar(50),
    department varchar(50)
);

--ダミーデータの作成
insert into employees
(id, name, department)
values
(1, 'm.fujita', 'Sales'),
(2, 'hue', 'Marketing'),
(3, 'naoki_yokozawa', 'Marketing'),
(4, 'Kaori', 'Sales'),
(5, 'Hiroki', 'Sales'),
(6, 'jinya_tonaik', 'Sales');

--2つ目のテーブル作成
create table sales (
    id int,
    employee_id int,
    sale_amount decimal(10, 2)
);

--ダミーデータの挿入
insert into sales
(id, employee_id, sale_amount)
values
(1, 1, 100.00),
(2, 1, 200.00),
(3, 2, 150.00),
(4, 4, 250.00),
(5, 3, 150.00),
(6, 5, 100.00),
(7, 2, 150.00),
(8, 4, 100.00);

--テーブル結合
create view employee_sales as
select
    e.id,
    e.name,
    e.department,
    s.sale_amount
from employees e
    join sales s
    on e.id = s.employee_id;

table employee_sales;

-- Streamの作成
create or replace stream stream_week38 on view employee_sales;

show streams;
select * from stream_week38;

-- データを削除してみる
delete from sales
where id = 1;

table sales;

select * from stream_week38;

--データをもう一度削除
delete from sales where id = 3;

table sales;

select * from stream_week38;

--削除データの確認テーブル作成
create or replace table deleted_table(
    id int,
    name varchar,
    department varchar,
    sale_amount decimal(10, 2 ),
    metadata$action varchar,
    metadata$isupdate boolean,
    metadata$row_id varchar,
    deleted_at timestamp default current_timestamp()
);

insert into deleted_table(
    id,name,department,sale_amount,metadata$action,metadata$isupdate,metadata$row_id
)
select
    id,name,department,sale_amount,metadata$action,metadata$isupdate,metadata$row_id
from stream_week38;

--タスク実行権限付与
use role accountadmin;
grant execute task on account to role sysadmin;
grant execute managed task on account to role sysadmin;

-- タスク作成
create or replace task deleted_data
target_completion_interval='1 minute'
when system$stream_has_data('stream_week38')
as
insert into deleted_table(
    id,name,department,sale_amount,metadata$action,metadata$isupdate,metadata$row_id)
select id,name,department,sale_amount,metadata$action,metadata$isupdate,metadata$row_id
from stream_week38;

show tasks;

-- 定期実行させる
alter task deleted_data resume;

-- 再度実行させる
alter task deleted_data resume;

-- 再度データを消して確認
delete from sales
where id = 4;

table deleted_table;

-- 定期実行を停止
alter task deleted_data suspend;