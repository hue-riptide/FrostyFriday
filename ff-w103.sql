--権限
use role sysadmin;
use warehouse compute_wh;

--データベース作成
create or replace database db_week103;
use database db_week103;
create or replace schema sales;
use schema sales;

create or replace table db_week103.sales.transactions (
    id INT,
    customer_name STRING,
    amount DECIMAL(10, 2),
    transaction_date TIMESTAMP
);

--DATA 作成
INSERT INTO sales.transactions 
(id, customer_name, amount, transaction_date) VALUES
(1, 'Alice', 100.00, '2024-07-20 10:00:00'), 
(2, 'Bob', 200.00, '2024-07-20 11:00:00'), 
(3, 'Charlie', 300.00, '2024-07-20 12:00:00')
;

--　#Issue 1 (three days ago)
update sales.transactions set amount = amount * 1.1 where id = 1;

delete from sales.transactions where id = 2;

table sales.transactions;

-- 8分前を確認
select * from sales.transactions
at (timestamp => dateadd('minute', -8, current_timestamp()));

table sales.transactions;

-- 8分前のデータでテーブル更新
create or replace table sales.transactions as 
select * 
from sales.transactions
at (timestamp => dateadd('minute', -8, current_timestamp()));



-- #Issue 2 (Yesterday)
delete from sales.transactions where id = 3;

create or replace table sales.transactions as
select * 
from sales.transactions
before (statement => LAST_QUERY_ID());

table sales.transactions;


--#Issue 3 (6 hours ago):
INSERT INTO sales.transactions (id, customer_name, amount, transaction_date)
SELECT id, customer_name, amount, transaction_date FROM sales.transactions;

table sales.transactions;

create or replace table sales.transactions as
select * 
from sales.transactions
at (timestamp => dateadd('minute', -1, current_timestamp()));


-- Clone
create or replace database db_week103_test
clone db_week103
before (statement=> '01c18768-0003-2415-0003-37c600021e76')
--at(timestamp => dateadd('minute', -10, current_timestamp()))
;

table db_week103_test.sales.transactions;